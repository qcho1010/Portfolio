# General Makefile notes
#
#	$<: the name of the prerequisite of the rule
#	$@: the name of the target of the rule (the LHS of the ":")
#	$^: the RHS of the ":"
CC = gcc
CFLAGS = -g 
OBJD = common.o
OBJS = master.o
OBJF = slave.o
SWIM = master
FISH = slave
DATA = cstest

.SUFFIXES: .c .o

all: $(SWIM) $(FISH)

$(SWIM): $(OBJS) $(OBJD)
	$(CC) -o $@ $^ -lm

$(FISH): $(OBJF) $(OBJD)
	$(CC) -o $@ $^ -lm

.c.o:
	$(CC) -c -o $@ $<

clean:
	rm -f *.o *.log $(SWIM) $(FISH) $(PELL) $(DATA)