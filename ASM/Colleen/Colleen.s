; Bism Ellah Elrahman Elraheem

default rel

section .data
	msg db "; Bism Ellah Elrahman Elraheem%c%cdefault rel%c%csection .data%c	msg db %c%s%c, 0%cextern printf%cglobal main%csection .text%cmain:%c	push rbp%c	mov rsi, 0xa ; entry point comment because I can do so%c	mov rdx, 0xa%c	mov r8, 0xa%c	mov r9, 0xa%c	mov rax, 0xa%c	sub rsp, 0x128%c	mov rdi, rsp%c	mov rcx, 37%c	cld  ;cld clears the x86 Direction Flag (DF) Without cld, if DF happened to be set, stosq would decrement RDI and write backward, potentially corrupting memory outside the allocated stack area.%c	rep stosq %c	push 0x22%c	lea rax, [msg]%c	push rax %c	push 0x22%c	xor rax, rax%c	mov rcx, 0xa%c	lea rdi, [msg]; entry point comment%c	call printf wrt ..plt%c	add rsp, 0x140%c	mov rdi, 0x2%c	mov rsi, 0x3%c	call add_two_numbers%c	xor rax, rax%c	pop rbp%c	ret%c%cadd_two_numbers:%c	xor rax, rax%c	add rax, rdi%c	add rax, rsi%c	ret%csection .note.GNU-stack noalloc noexec nowrite progbits ; tells the linker the stack is only used for data, not for executing instructions", 0
extern printf
global main
section .text
main:
	push rbp
	mov rsi, 0xa ; entry point comment because I can do so
	mov rdx, 0xa
	mov r8, 0xa
	mov r9, 0xa
	mov rax, 0xa
	sub rsp, 0x128
	mov rdi, rsp
	mov rcx, 37
	cld  ;cld clears the x86 Direction Flag (DF) Without cld, if DF happened to be set, stosq would decrement RDI and write backward, potentially corrupting memory outside the allocated stack area.
	rep stosq 
	push 0x22
	lea rax, [msg]
	push rax 
	push 0x22
	xor rax, rax
	mov rcx, 0xa
	lea rdi, [msg]; entry point comment
	call printf wrt ..plt
	add rsp, 0x140
	mov rdi, 0x2
	mov rsi, 0x3
	call add_two_numbers
	xor rax, rax
	pop rbp
	ret

add_two_numbers:
	xor rax, rax
	add rax, rdi
	add rax, rsi
	ret
section .note.GNU-stack noalloc noexec nowrite progbits ; tells the linker the stack is only used for data, not for executing instructions