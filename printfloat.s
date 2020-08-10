    .data
    numerito: .float -1.090
    
    dot: .asciz ","
    minus: .asciz "-"

    .text
MAIN:
    LDR R0, =numerito
    VLDR S0, [R0]
    BL PRINTFLOAT
    SWI    #0x11                @ Finalizo la ejecución del programa.
PRINTFLOAT:
    PUSH {R0, R1, R2}
    VPUSH {S0, S1, S2}
    
    MOV R0, #0
    
    VCMP.F32 S0, #0            @ Las condiciones sólo funcionan con los flags CPSR, con esta
    VMRS APSR_nzcv, FPSCR      @ línea clonamos las flags FCPSR en CPSR.
    LDRMI R1, =minus				@ Cargo el caracter '-'
    SWIMI 0x69
    
    VABS.F32 S0, S0             @ Obtengo el módulo
    
    MOV R1, #0
    ADD R1, #1000
    VMOV S1, R1
    VCVT.F32.U32 S1, S1 
    
    VCVT.U32.F32 S2, S0			@ Convierto el decimal a entero para obtener la unidad.
    VMOV R1, S2    

    SWI 0x6B                    @ Muestro la unidad.
    
    VCVT.F32.U32 S2, S2         @ Recupero el entero
    VSUB.F32 S0, S0, S2         @ Se lo resto al número original

    VMUL.F32 S0, S0, S1         
    VCVT.U32.F32 S2, S0
    VMOV R2, S2                 @ Obtengo los decimales.

    LDR R1, =dot
    SWILO 0x69
    
    CMP R2, #100                @ Si los decimales son menores a 100, agrego un 0
    BHS ZEROFIXED
    MOV R1, #0
    SWI 0x6B
    
    CMP R2, #10                 @ Si los decimales son menores a 10, agrego un 0
    BHS  ZEROFIXED
    MOV R1, #0
    SWI 0x6B
ZEROFIXED:
    MOV R1, R2
    SWI 0x6B

    VPOP {S0, S1, S2}
    POP {R0, R1, R2}
    MOV PC, LR