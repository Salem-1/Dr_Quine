NAME = Sully
SRC = Sully.c
OBJ = $(SRC:.c=.o)
CC= clang
CFLAGS = -Wall -Wextra -Werror

all: $(NAME)

%.o: %.s 
	$(CC) $(SRC) -o $(NAME)

$(NAME): $(OBJ)

run: all 
	./Sully

clean:
	rm -f $(OBJ)

fclean: clean
	rm -f $(NAME) 


re: fclean all

.PHONY: all clean fclean re