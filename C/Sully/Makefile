NAME = Sully
DIR =  Sully_children
SRC = Sully.c
OBJ = $(SRC:.c=.o)
CC= clang
CFLAGS = -Wall -Wextra -Werror

target:
	$(MAKE) -C ./$(DIR)
	
all: $(NAME)

%.o: %.s 
	$(CC) $(SRC) -o $(NAME)

$(NAME): $(OBJ)

run: wipe all 
	./Sully

clean:
	rm -f $(OBJ)

fclean: clean
	rm -f $(NAME) 


re: fclean all

wipe: fclean 
	rm -rf Sully_*


.PHONY: all clean fclean re wipe rewi