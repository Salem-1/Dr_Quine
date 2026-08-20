; Bism Ellah Elrahman Elraheem
extern fopen, fprintf, fclose
global main
default rel

%macro DELIVERY 0
	lea rdi, [child]
	lea rsi, [mode]
	call fopen wrt ..plt
	test rax, rax
	jz end_program
	mov rdi, rax
	mov [opened_file], rdi
	lea rsi, msg
	mov rdx, 0xa
	mov rcx, 0xa
	mov r8, 0xa
	mov r9, 0xa
	sub rsp, 0x2e8
	push 0xa
	push 0xa
	push 0xa
	push 0xa
	push 0xa
	push 0xa
	push 0xa
	push 0x25
	push 0xa
	push 0x25
	push 0xa
	push 0xa
	push 0x25
	push 0x25
	push 0xa
	push 0x7e
	push 0x7e
	push 0x7e
	push 0x7e
	push 0x7e
	push 0x7e
	push 0x7e
	push 0x7e
	push 0x7e
	push 0x7e
	push 0x7e
	push 0x25
	PUSH_NEWLINE 2
	push 0xa
	push 0x25
	PUSH_NEWLINE 2
	push 0x25
	PUSH_NEWLINE 57
	push 0x25
	push 0xa
	xor rax, rax
	call fprintf wrt ..plt
	mov rdi, [opened_file]
	call fclose wrt ..plt
	add rsp, 0x5e0
	xor rax, rax
end_program:
	ret
%endmacro

%macro VARS 0
	child db "Grace_kid.s", 0
	mode db "w", 0
	opened_file dq 0 
	msg db "; Bism Ellah Elrahman Elraheem%cextern fopen, fprintf, fclose%cglobal main%cdefault rel%c%c%cmacro DELIVERY 0%c	lea rdi, [child]%c	lea rsi, [mode]%c	call fopen wrt ..plt%c	test rax, rax%c	jz end_program%c	mov rdi, rax%c	mov [opened_file], rdi%c	lea rsi, msg%c	mov rdx, 0xa%c	mov rcx, 0xa%c	mov r8, 0xa%c	mov r9, 0xa%c	sub rsp, 0x2e8%c	push 0xa%c	push 0xa%c	push 0xa%c	push 0xa%c	push 0xa%c	push 0xa%c	push 0xa%c	push 0x25%c	push 0xa%c	push 0x25%c	push 0xa%c	push 0xa%c	push 0x25%c	push 0x25%c	push 0xa%c	push 0x7e%c	push 0x7e%c	push 0x7e%c	push 0x7e%c	push 0x7e%c	push 0x7e%c	push 0x7e%c	push 0x7e%c	push 0x7e%c	push 0x7e%c	push 0x7e%c	push 0x25%c	PUSH_NEWLINE 2%c	push 0xa%c	push 0x25%c	PUSH_NEWLINE 2%c	push 0x25%c	PUSH_NEWLINE 57%c	push 0x25%c	push 0xa%c	xor rax, rax%c	call fprintf wrt ..plt%c	mov rdi, [opened_file]%c	call fclose wrt ..plt%c	add rsp, 0x5e0%c	xor rax, rax%cend_program:%c	ret%c%cendmacro%c%c%cmacro VARS 0%c	child db %cGrace_kid.s%c, 0%c	mode db %cw%c, 0%c	opened_file dq 0 %c	msg db %c%s%c, 0xa, 0%c%cendmacro%c%cmacro PUSH_NEWLINE 1%c	%crep %c1%c		push 0xa%c	%cendrep%c%cendmacro%c%csection .data%cVARS%csection .text%cmain:%c	DELIVERY%c", 0xa, 0
%endmacro
%macro PUSH_NEWLINE 1
	%rep %1
		push 0xa
	%endrep
%endmacro

section .data
VARS
section .text
main:
	DELIVERY
