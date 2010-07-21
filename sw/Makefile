EXE = mcml_tm4

# Settings
CC = cc
FLAGS =

# TM4 Settings
TM=../lib/tmjports0_1/tmjports
LINUXPORTS = $(TM)/tmjports.a

LIB_DIR = -L. \
-L $(LINUXPORTS)

LIB = -lm

OBJ = mcml.o

H = mcml.h hw_parameters.h

# Targets
EXE: Makefile mcml_tm4.o $(OBJ) $(H) $(LINUXPORTS)
	$(CC) $(FLAGS) mcml_tm4.o $(OBJ) $(LINUXPORTS) -o $(EXE) $(LIB_DIR) $(LIB)

mcml.o: mcmlmain.c $(H)
	$(CC) $(FLAGS) mcmlmain.c $(INCLUDES) -c -o mcml.o

%.o:%.c $(H)
	$(CC) $(FLAGS) $(INCLUDES) -c $< -o $@

$(LINUXPORTS):
	cd $(TM) && make

clean:
	rm -f $(EXE) *.o $(OBJ)