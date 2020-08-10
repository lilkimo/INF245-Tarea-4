    .data
    string: .asciz "Dou"

    .text
    .global MAIN
MAIN:
    BL INPUT
    BL OUTPUT
    
    MOV R0, #0
    LDR R1, =string
    SWI 0x69
    CMP R0, R0
INPUT: @ Guarda en R0
    MOV R0, #0
    SWI 0x6C
    MOV PC, LR
OUTPUT: @ Printea R0
    PUSH {R1}
    MOV R1, R0
    
    MOV R0, #0
    SWI 0x6B
    
    POP {R1}
    MOV PC, LR