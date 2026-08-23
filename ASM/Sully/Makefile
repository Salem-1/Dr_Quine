
DIR =  Sully_children
SRC =  Sully.s

OBJ = $(DIR)/$(SRC:.s=.o)

ASM = nasm
ASMFLAGS = -f elf64 -Wall 
NAME = $(DIR)/Sully
CC = gcc



all: $(NAME)

$(DIR): 
	mkdir -p $(DIR)


$(NAME): $(DIR) $(OBJ)
	$(CC) $(OBJ) -o  $@   


$(DIR)/%.o: %.s | $(DIR) # the | $(DIR) ensure the output directory exists first
	$(ASM) $(ASMFLAGS) $< -o $@  #the first dependancy "Sully.s"; $@ the target "Sully.o"



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