#include <fcntl.h>
#include <stdio.h>
# define PROGRAM "#include <fcntl.h>%c#include <stdio.h>%c# define PROGRAM %c%s%c%c#define FT(x)int main(){ FILE * fd = fopen(%cGrace_kid.c%c, %cw%c);if (fd == NULL){printf(%cFailed to open the file%c); return(0);}fprintf(fd, PROGRAM, 10, 10, 34, PROGRAM, 34, 10, 34, 34, 34, 34, 34, 34, 10, 34, 34, 10, 10, 10);}%cFT(%chi%c);%c/*%c	This is a comment%c*/"
#define FT(x)int main(){ FILE * fd = fopen("Grace_kid.c", "w");if (fd == NULL){printf("Failed to open the file"); return(0);}fprintf(fd, PROGRAM, 10, 10, 34, PROGRAM, 34, 10, 34, 34, 34, 34, 34, 34, 10, 34, 34, 10, 10, 10);}
FT("hi");
/*
	This is a comment
*/