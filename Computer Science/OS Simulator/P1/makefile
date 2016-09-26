# General Makefile notes
#
#	$<: the name of the prerequisite of the rule
#	$@: the name of the target of the rule (the LHS of the ":")
#	$^: the RHS of the ":"
CC = gcc
CFLAGS = -g

MAINO = main.o
LOGO = loglib.o

MAIN = buggy_code

.SUFFIXES: .c .o

all: $(MAIN)

$(MAIN): $(MAINO) $(LOGO)
	$(CC) -o $@ $^ -lm

.c.o:
	$(CC) -c -o $@ $<

clean:
	rm *.o $(MAIN) *.log

pclean:
	rm *.o rm *.log
