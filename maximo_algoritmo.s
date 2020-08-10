    .data   
    length:  .word 6            @ [INPUT] Largo del array.
    array:   .word -4, -2, 18, -6, -3, -6 @ [INPUT] Array.
    
    .text
	.global	MAIN
MAIN:
    LDR    R0, =array           @ Cargo la dirección base del array en R0.
    LDR    R1, =length          
    LDR    R1, [R1]             @ Cargo el largo del array en R1.

    LDR    R2, [R0]             @ max = array[0];
    MOV    R3, #1               @ i = 1;
READLOOP:
    CMP    R1, R3
    BEQ    DONE                 @ while (length != i) {
    LDR    R4, [R0, R3, LSL #2] @     value = array[i];
    CMP    R2, R4               @     if (max < value)
    MOVLT  R2, R4               @         max = value;
    ADD    R3, R3, #1           @     i++;
    B      READLOOP             @ }
DONE:
    MOV    R0, R2               @ [RESULTADO] Guardamos el resultado en R0 por convención.
EXIT:
    MOV    R0, #0x18            @ Este segmento de código lo saqué del pdf que anexaste en las consultas de
    MOV    R1, #0               @ aula, y se encarga de finalizar el programa.
    SWI    0x123456