	.equ SCREEN_WIDTH, 		640
	.equ SCREEN_HEIGH, 		480
	.equ BITS_PER_PIXEL,  	32

	.equ GPIO_BASE,      0x3f200000
	.equ GPIO_GPFSEL0,   0x00
	.equ GPIO_GPLEV0,    0x34

	.globl main

main:
	// x0 contiene la direccion base del framebuffer
 	mov x20, x0	// Guarda la dirección base del framebuffer en x20
	//---------------- CODE HERE ------------------------------------

	movz x10, 0x0033, lsl 16
	movk x10, 0x0066, lsl 00

	mov x2, SCREEN_HEIGH         // Y Size
loop1:
	mov x1, SCREEN_WIDTH         // X Size
loop0:
	stur w10,[x0]  // Colorear el pixel N
	add x0,x0,4	   // Siguiente pixel
	sub x1,x1,1	   // Decrementar contador X
	cbnz x1,loop0  // Si no terminó la fila, salto
	sub x2,x2,1	   // Decrementar contador Y
	cbnz x2,loop1  // Si no es la última fila, salto


// DIBUJAR RECTANGULO
/* parametros, x12 alto, x14 ancho, x13 pixel x, x11 pixel y*/
dibujar_rectangulo:
  mov x1, SCREEN_WIDTH //en x1 esta SCREEN_WIDTH
  movz x10, 0xffc0, lsl 16 // color
  movk x10, 0xc0c0, lsl 00 // color
  
  mov x11, 200 // aqui va el pixel y inicial
  mov x12, 8 // alto deseado

rect_y_loop:
  cmp x12, 0
  beq fin_rect

  mov x13, 80 // aqui va el pixel x inicial
  mov x14, 480 // ancho deseado 

rect_x_loop:
  // offset = ((x * SCREEN_W)+x) * 4
  mov x15, x11
  mul x15, x15, x1
  add x15, x15, x13

  lsl x15, x15, 2

  add x15, x20, x15
  stur w10, [x15]

  add x13, x13, 1
  sub x14, x14, 1
  cbnz x14, rect_x_loop

  add x11, x11, 1
  sub x12, x12, 1
  b rect_y_loop

fin_rect:

	// Ejemplo de uso de gpios
	//mov x9, GPIO_BASE

	// Atención: se utilizan registros w porque la documentación de broadcom
	// indica que los registros que estamos leyendo y escribiendo son de 32 bits

	// Setea gpios 0 - 9 como lectura
	//str wzr, [x9, GPIO_GPFSEL0]

	// Lee el estado de los GPIO 0 - 31
	//ldr w10, [x9, GPIO_GPLEV0]

	// And bit a bit mantiene el resultado del bit 2 en w10
	//and w11, w10, 0b10

	// w11 será 1 si había un 1 en la posición 2 de w10, si no será 0
	// efectivamente, su valor representará si GPIO 2 está activo
	//lsr w11, w11, 1

// -------------------- SOL DEL FONDO //
circulo:
    mov x10, 320     // centroX
    mov x11, 530     // centroY
    mov x12, 320     // Radio

    mov x13, SCREEN_WIDTH  // ancho
    mov x14, SCREEN_HEIGH  // alto
    // color naranja
    movz x15, 0xFC4B, lsl 16
    movk x15, 0x08, lsl 00
    // fin color

    mov x1, 0              // asignamos y = 0
cicloY:
    cmp x1, x14
    bge finCirculo

    mov x2, 0              // asignamos x = 0
cicloX:
    cmp x2, x13
    bge finFila

    sub x3, x2, x10        // x3 = x - centroX
    sub x4, x1, x11        // x4 = y - centroY
    mul x3, x3, x3         // x3²
    mul x4, x4, x4         // x4²
    add x5, x3, x4         // x5 = x3² + x4²

    mul x6, x12, x12       // radio²
    cmp x5, x6
    bgt noPintar

    // offset = (y * width + x) * 4
    mul x7, x1, x13       // x7 = y * 4
    add x7, x7, x2	  // x7 + heigh
    lsl x7, x7, 2         // *4
    add x8, x20, x7       // dirección del pixel

    str w15, [x8]         // pinta pixel

noPintar:
    add x2, x2, 1
    b cicloX

finFila:
    add x1, x1, 1
    b cicloY

finCirculo:
  b InfLoop
	//---------------------------------------------------------------
	// Infinite Loop

 
seteo_rombo:
//todo menos x4 puede cambiarse a conveniencia
/*
memorias temporales utilizadas: x4, x6, x11, x17, x18, x19, x21, x22 y x23 
(x11 es el color utilizado) 
(x17 y x18 son SCREEN_WIDTH y SCREEN_HEIGH respectivamente)
*/
	mov x4, 0     //x4 es usado para decidir que parte del rombo falta
	mov x1, 320   //posicion del rombo en el eje X
	mov x19, 100  //x19 decide el tamaño del rombo
	mov x2, 240   //posicion del rombo en el eje Y
	b rombo
 
limite:
	//usando x6 para crear el limite de la fila
	mul x6, x23, x17
	add x6, x6, x21
	lsl x6, x6, 2
	add x6, x6, x20

	//actualizando x0 con los datos actuales de limites (punto a y eje Y)
	mul x0, x23, x17
	add x0, x0, x22
	lsl x0, x0, 2
	add x0, x0, x20

	//decidiendo a que parte del rombo ir
	cmp x4, 1
	beq semirombo1
	cmp x4, 2
	beq semirombo2
 
rombo:
	add x21, x1, x19  //punto B
	sub x22, x1, x19  //punto A
	sub x23, x18, x2  //preparando eje y para el calculo de direccion
	mul x0, x23, x17
	add x0, x0, x22
	lsl x0, x0, 2
	add x0, x0, x20
	add x4, x4, 1     //pasando al siguiente paso del rombo
	b limite
 
semirombo1:
	stur w11, [x0]    //cambiar a color de preferencia
	add x0, x0, 4
	cmp x0, x6
	ble semirombo1

	//actualizando datos para los limites
	add x22, x22, 1
	sub x21, x21, 1
	sub x23, x23, 1

	//decidiendo si pasar a la siguiente fila o ir al siguiente paso
	cmp x22, x1
	ble limite
	b rombo
 
semirombo2:
	stur w11, [x0]   //cambiar a color de preferencia
	add x0, x0, 4
	cmp x0, x6
	ble semirombo2

	//actualizando datos para los limites
	add x22, x22, 1
	sub x21, x21, 1
	add x23, x23, 1

	//decidiendo si pasar a la siguiente fila o ir al siguiente paso
	cmp x22, x1
	ble limite
	mov x4, 0   //reseteando x4 para preparar un proximo rombo
	b InfLoop   //final de la funcion

InfLoop:
	b InfLoop
