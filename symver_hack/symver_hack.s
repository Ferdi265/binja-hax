; vim: ft=asm
.section .text

.macro fix_symver sym ver
.extern \sym
.global __fix_\sym
__fix_\sym:
    jmp \sym
.symver __fix_\sym, \sym@\ver
.endm

fix_symver _ZdaPvm Qt_5
fix_symver _ZdlPvm Qt_5
fix_symver _ZSt24__throw_out_of_range_fmtPKcz Qt_5
fix_symver __cxa_throw_bad_array_new_length Qt_5
fix_symver _ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE9_M_createERmm Qt_5
