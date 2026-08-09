NAME = Grace
SRC = Grace.c
OBJ = $(SRC:.c=.o)
CC= clang
# CFLAGS = -Wall -Wextra -Werror

all: $(NAME)

%.o: %.s 
	$(CC) $(SRC) -o $(NAME)

$(NAME): $(OBJ)

run: all 
	./Grace

debug:
	$(CC) $(SRC)  -E -P $(NAME)

clean:
	rm -f $(OBJ)

fclean: clean
	rm -f $(NAME) 

re: fclean all

.PHONY: all clean fclean re