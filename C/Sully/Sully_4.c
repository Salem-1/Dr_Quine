#include <fcntl.h>
#include <stdio.h>
#include<string.h>
#include <stdlib.h>
#include <stdio.h>
#define S(x) #x
# define CRAZY_PARSER(check_me) ( (check_me) == 5 ? 53 :   strlen(__FILE__) != 9 ?  1 : strncmp(__FILE__, S(Sully_), 6) != 0 ? 2 : strcmp(&__FILE__[7], S(.c)) != 0 ? 3 :  __FILE__[6] > 48 && __FILE__[6] < 54 ? __FILE__[6]  : 4)
#define WRITE_ME_BRO(target_file, payload, ...) fprintf(target_file, payload __VA_OPT__(,) __VA_ARGS__)
int main(){
	int turn_off_counter = 52;
	char char_counter = (char)CRAZY_PARSER(turn_off_counter);if (--char_counter < 48)return (0);char fname[] = S(Sully_X.c);fname[6] = char_counter;FILE *sully_x = fopen(fname, S(w));if (sully_x == NULL)return (1);
	char *file_content = "#include <fcntl.h>%c#include <stdio.h>%c#include<string.h>%c#include <stdlib.h>%c#include <stdio.h>%c#define S(x) #x%c# define CRAZY_PARSER(check_me) ( (check_me) == 5 ? 53 :   strlen(__FILE__) != 9 ?  1 : strncmp(__FILE__, S(Sully_), 6) != 0 ? 2 : strcmp(&__FILE__[7], S(.c)) != 0 ? 3 :  __FILE__[6] > 48 && __FILE__[6] < 54 ? __FILE__[6]  : 4)%c#define WRITE_ME_BRO(target_file, payload, ...) fprintf(target_file, payload __VA_OPT__(,) __VA_ARGS__)%cint main(){%c	int turn_off_counter = %d;%c	char char_counter = (char)CRAZY_PARSER(turn_off_counter);if (--char_counter < 48)return (0);char fname[] = S(Sully_X.c);fname[6] = char_counter;FILE *sully_x = fopen(fname, S(w));if (sully_x == NULL)return (1);%c	char *file_content = %c%s%c;%c	WRITE_ME_BRO(sully_x, file_content,  0xa, 0xa, 0xa,  0xa, 0xa,  0xa , 0xa, 0xa,  0xa, char_counter,0xa, 0xa, 0x22, file_content, 0x22, 0xa, 0xa, 0xa);%c	fclose(sully_x);char command[60];sprintf(command, S(gcc -Wall -Wextra -Werror %cs -o Sully && ./Sully), fname);system(command);return 0;}";
	WRITE_ME_BRO(sully_x, file_content,  0xa, 0xa, 0xa,  0xa, 0xa,  0xa , 0xa, 0xa,  0xa, char_counter,0xa, 0xa, 0x22, file_content, 0x22, 0xa, 0xa, 0xa);
	fclose(sully_x);char command[60];sprintf(command, S(gcc -Wall -Wextra -Werror %s -o Sully && ./Sully), fname);system(command);return 0;}