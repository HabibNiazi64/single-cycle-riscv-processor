.section .text
.global _start

_start:
    # Set stack pointer (sp) safety line inside your valid Data Memory boundary
    # 0x000000FC points towards the end limit of a 64-word Data Memory array
    li sp, 0x000000FC  
    
    # Direct branches control to main context
    jal ra, main

_infinite_trap:
    j _infinite_trap
