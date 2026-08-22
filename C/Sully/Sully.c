int i = 5;
#include <fcntl.h>
#include <stdio.h>
#include<string.h>
#include <stdlib.h>

#define S(x) #x
#define FIRST_NLs(C)  C, 0xa, 0xa, 0xa,  0xa, 0xa,  0xa , 0xa, 0xa, 0xa, 0xa, 0xa, 0xa,  0xa, 0xa,  0xa , 0xa, 0xa, 0xa, 0xa
#define	LAST_F_CHAR_ARGS 0x22, 0xa, 0xa, 0xa, 0x25, 0x25, 0x25, 0xa, 0xa, 0xa, 0xa
# define TINY_PARSER(check_me) ((check_me) == 5 ? 53 :  __FILE__[6] > 47 && __FILE__[6] < 54 ? __FILE__[6]  : 4)

int main(){
	char file_counter = TINY_PARSER(i);
	if (--file_counter < 47)
		return (0);
	char fname[] = S(Sully_X.cl);
	if (file_counter == 47) {strcpy(fname, S(Sully_-1.c));} else {fname[6] = file_counter; fname[9] = 0;}
	FILE *sully_x = fopen(fname, S(w));char str_file_counter[] = S(XX); if (file_counter == 47) {strcpy(str_file_counter, S(-1));} else {str_file_counter[0] = file_counter; str_file_counter[1] = 0;}
	if (sully_x == NULL)
		return (1);
	char *file_content = "	int i = %s;%c#include <fcntl.h>%c#include <stdio.h>%c#include<string.h>%c#include <stdlib.h>%c%c#define S(x) #x%c#define FIRST_NLs(C)  C, 0xa, 0xa, 0xa,  0xa, 0xa,  0xa , 0xa, 0xa, 0xa, 0xa, 0xa, 0xa,  0xa, 0xa,  0xa , 0xa, 0xa, 0xa, 0xa%c#define	LAST_F_CHAR_ARGS 0x22, 0xa, 0xa, 0xa, 0x25, 0x25, 0x25, 0xa, 0xa, 0xa, 0xa%c# define TINY_PARSER(check_me) ((check_me) == 5 ? 53 :  __FILE__[6] > 47 && __FILE__[6] < 54 ? __FILE__[6]  : 4)%cint main(){%c	char file_counter = TINY_PARSER(i);%c	if (--file_counter < 47)%c		return (0);%c	char fname[] = S(Sully_X.cl);%c	if (file_counter == 47) {strcpy(fname, S(Sully_-1.c));} else {fname[6] = file_counter; fname[9] = 0;}%c	FILE *sully_x = fopen(fname, S(w));char str_file_counter[] = S(XX); if (file_counter == 47) {strcpy(str_file_counter, S(-1));} else {str_file_counter[0] = file_counter; str_file_counter[1] = 0;}%c	if (sully_x == NULL)%c		return (1);%c	char *file_content = %c%s%c;%c	fprintf(sully_x, file_content,  FIRST_NLs(str_file_counter), 0x22, file_content,LAST_F_CHAR_ARGS);%c	fclose(sully_x);char command[90];%c	sprintf(command, S(clang -Wall -Wextra -Werror %cs -o Sully_%cs && ./Sully_%cs), fname, str_file_counter, str_file_counter);%c	system(command);%c	return 0;%c}";
	fprintf(sully_x, file_content,  FIRST_NLs(str_file_counter), 0x22, file_content,LAST_F_CHAR_ARGS);
	fclose(sully_x);char command[90];
	sprintf(command, S(clang -Wall -Wextra -Werror %s -o Sully_%s && ./Sully_%s), fname, str_file_counter, str_file_counter);
	system(command);
	return 0;
}