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

// INTENTO DE CIRCULO (QUIZAS SIRVA PARA TRIANGULO)
/*

dibujarCirculo:
  movz x10, 0xff80, lsl 16
  movk x10, 0xff00, lsl 00 // color verde

  // Framebuffer: x20
  mov x1, SCREEN_WIDTH// SCREEN_W: x1, SCREEN_H: x2

  mov x11, 300        // Y inicial
  mov x12, 50        // Diámetro
  mov x13, 310        // X inicial izquierda
  mov x14, 330        // X inicial derecha
  mov x15, 1          // Delta expansión
  mov x16, 0          // Iterador vertical
  
  lsr x19, x12, 1     // radio = diam / 2

linea_circulo:
  // x21 = ax actual (izquierda)
  // x22 = bx actual (derecha)
  sub x21, x13, x16, lsl #2  // x21 = x13 - 4*i
  add x22, x14, x16, lsl #2  // x22 = x14 + 4*i

  // Calcular dirección de inicio (x21, y)
  mov x5, x11
  mul x5, x5, x1
  add x5, x5, x21
  lsl x5, x5, 2
  add x17, x20, x5

  // Calcular dirección de fin (x22, y)
  mov x6, x11
  mul x6, x6, x1
  add x6, x6, x22
  lsl x6, x6, 2
  add x18, x20, x6

pintar_linea:
  cmp x17, x18
  bge siguiente_linea
  stur w10, [x17]
  add x17, x17, 4
  b pintar_linea

siguiente_linea:
  cmp x16, x19
  beq fin_circulo

  add x11, x11, 1     // bajar una línea
  add x16, x16, 1     // i++

  b linea_circulo

fin_circulo:

*/

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

/*
circulo:
    mov x10, 320     // centroX
    mov x11, 480     // centroY
    mov x12, 250     // Radio

    mov x13, SCREEN_WIDTH  // ancho
    mov x14, SCREEN_HEIGH  // alto
    mov x15, 0x2d00    // color

    mov x1, 0              // y = 0
cicloY:
    cmp x1, x14
    bge finCirculo

    mov x2, 0              // x = 0
cicloX:
    cmp x2, x13
    bge finFila

    // dx = x - centroX
    sub x3, x2, x10
    // dy = y - centroY
    sub x4, x1, x11
    // dx^2
    mul x3, x3, x3
    // dy^2
    mul x4, x4, x4
    // distancia² = dx^2 + dy^2
    add x5, x3, x4

    // radio²
    mul x6, x12, x12
    cmp x5, x6
    bgt noPintar

    // offset = (y * width + x) * 4
    mul x7, x1, x13
    add x7, x7, x2
    lsl x7, x7, 2         // *4
    add x8, x20, x7       // dirección del pixel

    str w15, [x8]         // pintar pixel

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
*/ 
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
