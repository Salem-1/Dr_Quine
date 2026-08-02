NAME = Colleen
SRC = Colleen.c
OBJ = $(SRC:.c=.o)
CC= gcc
# CFLAGS = -wall -wextra -werror

all: $(NAME)

%.o: %.s 
	$(CC) $(SRC) -o $(NAME)

$(NAME): $(OBJ)

run: all 
	./Colleen

clean:
	rm -f $(OBJ)

fclean: clean
	rm -f $(NAME) 

re: fclean all

.PHONY: all clean fclean re