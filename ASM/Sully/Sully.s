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
        mov rcx, 0x22
        mov r8, 0x25
        mov r9, msg
        xor rax, rax
        call fprintf wrt ..plt
        mov rdi, [opened_file]
        call fclose wrt ..plt
        xor rax, rax
end_program:
        ret
%endmacro

%macro VARS 0
        child db "Grace_kid.s", 0
        mode db "w", 0
        opened_file dq 0 
	msg db "; Bism Ellah Elrahman Elraheem%1$cextern fopen, fprintf, fclose%1$cglobal main%1$cdefault rel%1$c%1$c%3$cmacro DELIVERY 0%1$c        lea rdi, [child]%1$c        lea rsi, [mode]%1$c        call fopen wrt ..plt%1$c        test rax, rax%1$c        jz end_program%1$c        mov rdi, rax%1$c        mov [opened_file], rdi%1$c        lea rsi, msg%1$c        mov rdx, 0xa%1$c        mov rcx, 0x22%1$c        mov r8, 0x25%1$c        mov r9, msg%1$c        xor rax, rax%1$c        call fprintf wrt ..plt%1$c        mov rdi, [opened_file]%1$c        call fclose wrt ..plt%1$c        xor rax, rax%1$cend_program:%1$c        ret%1$c%3$cendmacro%1$c%1$c%3$cmacro VARS 0%1$c        child db %2$cGrace_kid.s%2$c, 0%1$c        mode db %2$cw%2$c, 0%1$c        opened_file dq 0 %1$c	msg db %2$c%4$s%2$c, 0%1$c%3$cendmacro%1$c%1$c%1$csection .data%1$c	VARS%1$csection .text%1$cmain:%1$c        DELIVERY%1$c%1$c%1$c		%1$c", 0
%endmacro


section .data
	VARS
section .text
main:
        DELIVERY


		
