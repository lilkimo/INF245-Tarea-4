    .data
    @ Constante de transformación de grado hexadecimal a radianes.
    deg2rad:     .float 0.01745329251994329576923690768489

    dot:         .asciz ","
    minus:       .asciz "-"

    inputMsg:    .asciz "Ingrese un ángulo: "
    output1Msg:  .asciz "Cos("
    output2Msg:  .asciz ") = "

    .text
	.global	MAIN 
MAIN:                               @ Trabajo con los registros 4-11 en el main por convención.
    MOV          R0, #0
    LDR          R1, =inputMsg
    SWI          0x69
    
    MOV          R0, #0
    SWI          0x6C                @ Pido por consola el ángulo cuyo coseno se desea averiguar.
    MOV          R4, R0              @ Almaceno en R4 el valor del ángulo en grados hexadecimales.
    MOV          R7, R0              @ Almaceno en R7 para printerlo al final del programa.

    @ La serie de taylor tiene un error de 0.0008 en el intervalo [-π/2, π/2], por ende hay que
    @ normalizar el ángulo de entrada.
    SUB          R4, #14            @ El valor máximo de un inmediato es 256, por lo que para hacer
    CMP          R4, #256           @ la comparación 'angulo < 270' resto 14 en ambos lados.
    ADD          R4, #14            @ Recupero el valor original del ángulo.
    BGT          BTW270AND360
    
    CMP          R4, #90
    BGT          BTW90AND270
    
    B            ANGLE_DONE         @ Si el ángulo se encuentra entre [0, π/2] no hay necesidad de normalizarlo.
BTW270AND360:                       @ Si el ángulo se encuentra entre [3π/2, 2π] saco su complemento a 360
    SUB          R4, #360           @ para dejarlo en el intervalo [-π/2, 0].
    B            ANGLE_DONE
BTW90AND270:                        @ Nuestra serie de taylor no cubre el intervalo [π/2, 3π/2], pero como el
    SUB          R4, #180           @ coseno es periódico y par podemos calcularlo como -cos(complemento a 180).
    MOV          R6, #1             @ Esta flag nos indicará más tarde que hay que mutiplicar el resultado por -1.
ANGLE_DONE:
    VMOV         S4, R4
    VCVT.F32.S32 S4, S4             @ float.parse(Ángulo)

    LDR          R4, = deg2rad      
    VLDR         S0, [R4]           @ Cargo la constante que transforma de grados a radianes.
    
    VMUL.F32     S4, S4, S0         @ x         = Ángulo normalizado en radianes.

    MOV          R4, #0xFFFFFFFF    @ signo     = -1
    MOV          R5, #0xFFFFFFFE    @ inversor; Con la operación (signo XOR inversor) obtengo la cadena 1, -1, 1, -1, 1, -1...
SUMMATION:
    VMOV         S0, S4             @ x
    LSL          R0, R2, #1         @ 2*n;   R2 = n
    
    BL           POW                @ x^(2*n)
    
    BL           FACTORIAL          @ (2*n)!
    VMOV         S1, R0
    VCVT.F32.U32 S1, S1             @ float.parse((2*n)!)

    VDIV.F32     S0, S0, S1         @ termino = x^(2*n)/(2*n)!
    
    EOR          R4, R5             @ signo     = (-1)^n
    CMP          R4, #1             @ if (signo != 1)
    VNEGNE.F32   S0, S0             @     termino = -termino

    VADD.F32     S5, S0, S5         @ sum += termino; S5 = sum
    
    CMP          R2, #3             @ if (n >= 3) break
    ADD          R2, R2, #1         @ n++
    BNE          SUMMATION

    CMP          R6, #1             @ Si la flag 'angulo pertenece a [π/2, 3π/2]' está activa, multiplicamos el
    VNEGEQ.F32   S5, S5             @ valor de cos(x) por -1, puesto que estamos calculando el ángulo contrario.
    
    MOV          R0, #0
    LDR          R1, =output1Msg
    SWI          0x69
    MOV          R1, R7
    SWI          0x6B
    LDR          R1, =output2Msg
    SWI          0x69

    VMOV         S0, S5             
    BL           PRINTFLOAT         @ Muestro por consola el resultado de la sumatoria

    SWI          0x11               @ Finalizo la ejecución del programa.

POW:                                @ S0^R0
    MOV          R1, #1             @ Establezco el resultado de la función como 1.
    VMOV         S1, R1
    VCVT.F32.U32 S1, S1
    MOV          R1, #0             @ Contador para ver en qué potencia voy.
POW_MULLOOP:
    CMP          R0, R1             @ Si ya alcancé la potencia deseada retorno.
    BEQ          POW_DONE
    VMUL.F32     S1, S0, S1         @ S0^potenciaActual
    ADD          R1, #1             @ potenciaActual++
    B            POW_MULLOOP
POW_DONE:
    VMOV         S0, S1             @ Muevo el resultado a S0 por convención.
    MOV          PC, LR

FACTORIAL:                          @ R0!
    PUSH         {R0, LR}
    CMP          R0, #1
    BGT          FACTORIAL_ELSE
    MOV          R0, #1
    ADD          SP, SP, #8
    MOV          PC, LR
FACTORIAL_ELSE:
    SUB          R0, R0, #1
    BL           FACTORIAL
    POP          {R1, LR}
    MUL          R0, R1, R0
    MOV          PC, LR

PRINTFLOAT:                         @ Muestra en consola S0
    PUSH         {R0, R1, R2}
    VPUSH        {S0, S1, S2}
    
    MOV          R0, #0
    
    VCMP.F32     S0, #0             @ Las condiciones sólo funcionan con los flags CPSR, con esta
    VMRS         APSR_nzcv, FPSCR   @ línea clonamos las flags FCPSR en CPSR.
    LDRMI        R1, =minus	        @ Si el número es negativo,
    SWIMI        0x69               @ muestro en consola el caracter '-'.
    
    VABS.F32     S0, S0             @ Obtengo el módulo.
    
    MOV          R1, #0             
    ADD          R1, #1000          
    VMOV         S1, R1
    VCVT.F32.U32 S1, S1             @ Almaceno en S1 el valor de 1000 para obtener los 3 decimales más tarde.
    
    VCVT.U32.F32 S2, S0			    @ Convierto el decimal a entero para obtener la unidad.
    VMOV         R1, S2    

    SWI 0x6B                        @ Muestro en consola la unidad.
    
    VCVT.F32.U32 S2, S2             @ Recupero el entero.
    VSUB.F32     S0, S0, S2         @ Se lo resto al número original.

    VMUL.F32     S0, S0, S1         @ Multiplico la parte decimal por 1000.
    VCVT.U32.F32 S2, S0             @ Obtengo los primeros 3 decimales.     
    VMOV         R2, S2             @ Muevo los decimales a un registro printeable.

    LDR          R1, =dot           
    SWILO        0x69               @ Muestro por consola el caracter '.'
    
    CMP          R2, #100           
    BHS          ZEROFIXED
    MOV          R1, #0             
    SWI          0x6B               @ Si los decimales son menores a 100, agrego un 0.
    
    CMP          R2, #10            
    BHS          ZEROFIXED
    MOV          R1, #0             
    SWI          0x6B               @ Si los decimales son menores a 10, agrego un 0.
ZEROFIXED:
    MOV          R1, R2
    SWI          0x6B               @ Muestro en consola los decimales restantes.

    VPOP         {S0, S1, S2}
    POP          {R0, R1, R2}
    MOV          PC, LR