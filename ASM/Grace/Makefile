
SRC =  Grace.s

OBJ = $(SRC:.s=.o)

ASM = nasm
ASMFLAGS = -f elf64 
NAME = Grace 
CC = gcc



all: $(NAME)

$(NAME): $(OBJ)
	$(CC)  $(OBJ) -o $(NAME)

%.o: %.s
	$(ASM) $(ASMFLAGS) $< -o $@


run: repru 
	./Grace

clean:
	rm -f $(OBJ)

fclean: clean
	rm -f $(NAME)

prune: fclean
	rm -rf Grace_kid.c

re: fclean all

repru: prune re

.PHONY: all clean fclean re prune repru