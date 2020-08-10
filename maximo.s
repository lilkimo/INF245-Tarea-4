    .data   
    array:       .skip 100*4    @ 100 elementos * 4 bytes (Un arreglo de 100 de largo)
    
    inputLenMsg: .asciz "Largo del arreglo: "
    inputValMsg: .asciz "Ingrese un valor: "
    outputMsg:   .asciz "El valor máximo del arreglo es: "

    .text
MAIN:
    MOV    R0, #0
    LDR    R1, =inputLenMsg
    SWI    0x69
    
    MOV    R0, #0
    SWI    0x6C                 @ Leo el largo del array de stdin/stdout/stderr
    MOV    R2, R0               @ Cargo el largo del array en R2.

    LDR    R3, =array           @ Cargo la dirección base del array en R3.
    MOV    R4, #0               @ i = 0; 
AVALUESLOOP:
    CMP    R4, R2               
    BEQ    FINDMAX              @ while (length != i) {  
    
    MOV    R0, #0
    LDR    R1, =inputValMsg
    SWI    0x69
    SWI    0x6C                 @     value = input();

    STR    R0, [R3, R4, LSL #2] @     array[i] = value;
    ADD    R4, R4, #1           @     i++
    B      AVALUESLOOP          @ }
FINDMAX:
    MOV    R0, R3               @ Guardo la dirección base del array en R0.
    MOV    R1, R2               @ Almaceno el largo del array en R1.
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
    MOV    R0, #0
    LDR    R1, =outputMsg
    SWI    0x69
    MOV    R1, R2               
    SWI    0x6B                 @ Muestro en consola el máximo valor del array.

    SWI    #0x11                @ Finalizo la ejecución del programa.