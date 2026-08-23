; int i = 5
; Bism Ellah Elrahman Elraheem
extern fopen, fprintf, fclose, sprintf
global main
default rel

%macro DELIVERY 0
    lea rdi, [file_name]
    lea rsi, [mode]
    call fopen wrt ..plt
    test rax, rax
    jz end_program
    mov rdi, rax
    mov [opened_file], rdi
    lea rsi, msg
    mov rdx, 0xa
    mov rcx, 0x22
    mov r8, 0x25
    lea r9, msg
	movzx  r10, byte [i] 
	add r10, 0x30
	push r10
    xor rax, rax
    call fprintf wrt ..plt
	add rsp, 8
    mov rdi, [opened_file]
    call fclose wrt ..plt
%endmacro

%macro VARS 0
	i db 0x5
    file_name db "Sully_X.s", 0
    zero_file_name db "Sully_-1.s", 0
    mode db "w", 0
    opened_file dq 0 
	msg db "; int i = %5$c%1$c; Bism Ellah Elrahman Elraheem%1$cextern fopen, fprintf, fclose, sprintf%1$cglobal main%1$cdefault rel%1$c%1$c%3$cmacro DELIVERY 0%1$c    lea rdi, [file_name]%1$c    lea rsi, [mode]%1$c    call fopen wrt ..plt%1$c    test rax, rax%1$c    jz end_program%1$c    mov rdi, rax%1$c    mov [opened_file], rdi%1$c    lea rsi, msg%1$c    mov rdx, 0xa%1$c    mov rcx, 0x22%1$c    mov r8, 0x25%1$c    lea r9, msg%1$c	movzx  r10, byte [i] %1$c	add r10, 0x30%1$c	push r10%1$c    xor rax, rax%1$c    call fprintf wrt ..plt%1$c	add rsp, 8%1$c    mov rdi, [opened_file]%1$c    call fclose wrt ..plt%1$c%3$cendmacro%1$c%1$c%3$cmacro VARS 0%1$c	i db 0x5%1$c    file_name db %2$cSully_X.s%2$c, 0%1$c    zero_file_name db %2$cSully_-1.s%2$c, 0%1$c    mode db %2$cw%2$c, 0%1$c    opened_file dq 0 %1$c	msg db %2$c%4$s%2$c, 0%1$c	command_sart db %2$cnasm -f elf64 Sully_%3$c1$c.s -o Sully_%3$c1$c.o && gcc Sully_%3$c1$c.o -o Sully_%3$c1$c && ./Sully_%3$c1$c%2$c, 0%1$c	command times 90 db 0%1$c%3$cendmacro%1$c%1$csection .data%1$c	VARS%1$c	%1$csection .text%1$cmain:%1$c	push rbp%1$c	mov rbp, rsp%1$c	mov al , [i]%1$c	cmp al, 0x0%1$c	jl end_program%1$c	je negative_one_file%1$c%1$cedit_file_name:%1$c	dec al %1$c	mov [i], al %1$c	add al, 0x30%1$c	lea rcx, file_name%1$c	mov [rcx + 6], al %1$c	; create file name if needed%1$c	jmp write_file%1$c%1$cnegative_one_file:%1$c%1$cwrite_file:%1$c    DELIVERY%1$c%1$c	; apply the command%1$c%1$ccommand_to_expand:%1$c	lea rdi, command%1$c	lea rsi, command_sart%1$c	mov cl, [i]%1$c	add cl, 0x30%1$c	movzx rdx, cl%1$c	xor rax, rax%1$c	call sprintf wrt ..plt%1$c%1$c%1$cend_program:%1$c	xor rax, rax%1$c	pop rbp%1$c	ret%1$c", 0
	command_sart db "nasm -f elf64 Sully_%1$c.s -o Sully_%1$c.o && gcc Sully_%1$c.o -o Sully_%1$c && ./Sully_%1$c", 0
	command times 90 db 0
%endmacro

section .data
	VARS
	
section .text
main:
	push rbp
	mov rbp, rsp
	mov al , [i]
	cmp al, 0x0
	jl end_program
	je negative_one_file

edit_file_name:
	dec al 
	mov [i], al 
	add al, 0x30
	lea rcx, file_name
	mov [rcx + 6], al 
	; create file name if needed
	jmp write_file

negative_one_file:

write_file:
    DELIVERY

	; apply the command

command_to_expand:
	lea rdi, command
	lea rsi, command_sart
	mov cl, [i]
	add cl, 0x30
	movzx rdx, cl
	xor rax, rax
	call sprintf wrt ..plt


end_program:
	xor rax, rax
	pop rbp
	ret
