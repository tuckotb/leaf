.global _start

.section .text.entry, "ax"
_start:
	lis     1, _stack_top@h
    ori     1, 1, _stack_top@l
    clrrwi  1, 1, 4

    li      0, 0
    stwu    0, -16(1)

    lis     3, _bss_start@h        
    ori     3, 3, _bss_start@l    
    lis     4, _bss_end@h          
    ori     4, 4, _bss_end@l      

    li      0, 0                   

.L_check_bss:
    cmplw   3, 4                  
    bge     .L_bss_done             

.L_loop_bss:
    stw     0, 0(3)               
    addi    3, 3, 4               
    cmplw   3, 4                  
    blt     .L_loop_bss             

.L_bss_done:
	bl kmain
