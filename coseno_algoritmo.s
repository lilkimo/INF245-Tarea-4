    .data
    deg2rad: .float 0.01745329251994329576923690768489
    angle: .word 257                @ [INPUT] Aquí va el ángulo a coseno calcular.

    .text
	.global	MAIN
MAIN:                               @ Trabajo con los registros 4-11 en el main por convención.
    LDR          R4, =angle           
    LDR          R4, [R4]           @ x         = Ángulo en grados.

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
SUMMATION_DONE:
    CMP          R6, #1             @ Si la flag 'angulo pertenece a [π/2, 3π/2]' está activa, multiplicamos el
    VNEGEQ.F32   S5, S5             @ valor de cos(x) por -1, puesto que estamos calculando el ángulo contrario.
    VMOV         S0, S5             @ [RESULTADO] Muevo el resultado de la sumatoria (sum) a S0 por convención.
EXIT:
    MOV          R0, #0x18          @ Este segmento de código lo saqué del pdf que anexaste en las consultas de
    MOV          R1, #0             @ aula, y se encarga de finalizar el programa.
    SWI          0x123456

POW:                                @ S0^R0
    MOV          R1, #1
    VMOV         S1, R1
    VCVT.F32.U32 S1, S1
    MOV          R1, #0
POW_MULLOOP:
    CMP          R0, R1
    BEQ          POW_DONE
    VMUL.F32     S1, S0, S1
    ADD          R1, #1
    B            POW_MULLOOP
POW_DONE:
    VMOV         S0, S1
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