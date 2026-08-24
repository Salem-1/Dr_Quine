
SRC =  Colleen.s

OBJ = $(SRC:.s=.o)

ASM = nasm
ASMFLAGS = -f elf64 
NAME = Colleen 
CC = gcc



all: $(NAME)

run: all 
	./Colleen

%.o: %.s
	$(ASM) $(ASMFLAGS) $< -o $@

$(NAME): $(OBJ)
	$(CC)  $(OBJ) -o $(NAME)


clean:
	rm -f $(OBJ)

fclean: clean
	rm -f $(NAME)

re: fclean all