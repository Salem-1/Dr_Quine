; int i = 2
; Bism Ellah Elrahman Elraheem
extern fopen, fprintf, fclose, sprintf, system
global main
default rel

%macro PUSH_FILE_NUM_STRING 0
	sub rsp, 8   
	movsx  r10, byte [i]
	cmp r10, 0x0
	jl %%justpushwhatwehave
	add r10, 0x30
	mov [num_to_update],  r10b
	mov r10, 0x0
	mov [num_to_update + 1],  r10b
	
%%justpushwhatwehave:
	lea r10, num_to_update
	push r10
%endmacro

%macro DELIVERY 1
    lea rdi, [%1]
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
	PUSH_FILE_NUM_STRING
    xor rax, rax
    call fprintf wrt ..plt
	add rsp, 16
    mov rdi, [opened_file]
    call fclose wrt ..plt
%endmacro

%macro VARS 0
	i db 5
    file_name db "Sully_X.s", 0
    negative_one_file_name db "Sully_-1.s", 0
    mode db "w", 0
    opened_file dq 0 
	msg db "; int i = %5$s%1$c; Bism Ellah Elrahman Elraheem%1$cextern fopen, fprintf, fclose, sprintf, system%1$cglobal main%1$cdefault rel%1$c%1$c%3$cmacro PUSH_FILE_NUM_STRING 0%1$c	sub rsp, 8   %1$c	movsx  r10, byte [i]%1$c	cmp r10, 0x0%1$c	jl %3$c%3$cjustpushwhatwehave%1$c	add r10, 0x30%1$c	mov [num_to_update],  r10b%1$c	mov r10, 0x0%1$c	mov [num_to_update + 1],  r10b%1$c	%1$c%3$c%3$cjustpushwhatwehave:%1$c	lea r10, num_to_update%1$c	push r10%1$c%3$cendmacro%1$c%1$c%3$cmacro DELIVERY 1%1$c    lea rdi, [%3$c1]%1$c    lea rsi, [mode]%1$c    call fopen wrt ..plt%1$c    test rax, rax%1$c    jz end_program%1$c    mov rdi, rax%1$c    mov [opened_file], rdi%1$c    lea rsi, msg%1$c    mov rdx, 0xa%1$c    mov rcx, 0x22%1$c    mov r8, 0x25%1$c    lea r9, msg%1$c	PUSH_FILE_NUM_STRING%1$c    xor rax, rax%1$c    call fprintf wrt ..plt%1$c	add rsp, 16%1$c    mov rdi, [opened_file]%1$c    call fclose wrt ..plt%1$c%3$cendmacro%1$c%1$c%3$cmacro VARS 0%1$c	i db 5%1$c    file_name db %2$cSully_X.s%2$c, 0%1$c    negative_one_file_name db %2$cSully_-1.s%2$c, 0%1$c    mode db %2$cw%2$c, 0%1$c    opened_file dq 0 %1$c	msg db %2$c%4$s%2$c, 0%1$c	command_start db %2$cnasm -f elf64 Sully_%3$c1$c.s -o Sully_%3$c1$c.o && gcc Sully_%3$c1$c.o -o Sully_%3$c1$c && ./Sully_%3$c1$c && rm -rf Sully_%3$c1$c%2$c, 0%1$c	command times 90 db 0%1$c	num_to_update db %2$c-1%2$c%1$c	our_file db __FILE__, 0x0%1$c%3$cendmacro%1$c%1$csection .data%1$c	VARS%1$c	%1$csection .text%1$cmain:%1$c	push rbp%1$c	mov rbp, rsp%1$c	mov al, [our_file + 6]%1$c	cmp al, 0x2d%1$c	je end_program%1$c	cmp al, 0x73%1$c	je first_round%1$c%1$cnormal_round:%1$c	sub al, 0x30%1$c	jmp continue_round%1$c%1$cfirst_round:%1$c	mov al, 0x5%1$c%1$ccontinue_round:%1$c	mov [i], al%1$c	cmp al, 0x0%1$c	je negative_one_file%1$c	%1$cedit_file_name:%1$c	dec al %1$c	mov [i], al %1$c	add al, 0x30%1$c	lea rcx, file_name%1$c	mov [rcx + 6], al %1$c	; create file name if needed%1$c	jmp write_file%1$c%1$cnegative_one_file:%1$c	dec al %1$c	mov [i], al %1$c%1$c%1$cwrite_file:%1$c	mov al, [i]%1$c	cmp al, 0x0%1$c	jge write_a_normal_file%1$c	jmp write_a_negative_one_file%1$c%1$cwrite_a_normal_file:%1$c    DELIVERY file_name%1$c	jmp command_to_expand%1$c%1$cwrite_a_negative_one_file:%1$c	DELIVERY negative_one_file_name%1$c	%1$c%1$c%1$ccommand_to_expand:%1$c	lea rdi, command%1$c	lea rsi, command_start%1$c	mov cl, [i]%1$c	add cl, 0x30%1$c	movzx rdx, cl%1$c	xor rax, rax%1$c	call sprintf wrt ..plt%1$c	lea rdi, command%1$c	call system wrt ..plt%1$c%1$c%1$c%1$cend_program:%1$c	xor rax, rax%1$c	pop rbp%1$c	ret%1$c", 0
	command_start db "nasm -f elf64 Sully_%1$c.s -o Sully_%1$c.o && gcc Sully_%1$c.o -o Sully_%1$c && ./Sully_%1$c && rm -rf Sully_%1$c", 0
	command times 90 db 0
	num_to_update db "-1"
	our_file db __FILE__, 0x0
%endmacro

section .data
	VARS
	
section .text
main:
	push rbp
	mov rbp, rsp
	mov al, [our_file + 6]
	cmp al, 0x2d
	je end_program
	cmp al, 0x73
	je first_round

normal_round:
	sub al, 0x30
	jmp continue_round

first_round:
	mov al, 0x5

continue_round:
	mov [i], al
	cmp al, 0x0
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
	dec al 
	mov [i], al 


write_file:
	mov al, [i]
	cmp al, 0x0
	jge write_a_normal_file
	jmp write_a_negative_one_file

write_a_normal_file:
    DELIVERY file_name
	jmp command_to_expand

write_a_negative_one_file:
	DELIVERY negative_one_file_name
	


command_to_expand:
	lea rdi, command
	lea rsi, command_start
	mov cl, [i]
	add cl, 0x30
	movzx rdx, cl
	xor rax, rax
	call sprintf wrt ..plt
	lea rdi, command
	call system wrt ..plt



end_program:
	xor rax, rax
	pop rbp
	ret
