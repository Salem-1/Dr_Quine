DIR =  Sully_children
NAME = $(DIR)/Sully
SRC = Sully.c
CC= clang
CFLAGS = -Wall -Wextra -Werror

OBJ = $(SRC:%.c=%.o)

all: $(NAME)

$(DIR): 
	mkdir -p $(DIR)

$(NAME): $(DIR) $(OBJ)
	$(CC) $(OBJ) -o  $@   

$(DIR)/%.o: %.c | $(DIR) # the | $(DIR) ensure the output directory exists first
	$(CC) $(CFLAGS) -c $< -o $@  #the first dependancy "Sully.c"; $@ the target "Sully.o"

run: all 
	cd $(DIR) && ./Sully

clean:
	rm -f $(OBJ)

fclean: clean
	rm -f $(NAME) 


re: fclean all

wipe: fclean 
	rm -rf $(DIR)


.PHONY: all clean fclean re wipe rewi