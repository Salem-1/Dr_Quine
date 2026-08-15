NAME = Grace
SRC = Grace.c
OBJ = $(SRC:.c=.o)
CC= clang
# CFLAGS = -Wall -Wextra -Werror

all: $(NAME)

%.o: %.s 
	$(CC) $(SRC) -o $(NAME)

$(NAME): $(OBJ)

run: repru 
	./Grace

debug:
	$(CC) $(SRC)  -E -P $(NAME)

clean:
	rm -f $(OBJ)

fclean: clean
	rm -f $(NAME) 

prune: fclean
	rm -rf Grace_kid.c

re: fclean all

repru: prune re
.PHONY: all clean fclean re