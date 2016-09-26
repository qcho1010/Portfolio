# Makefile for CS4760 p6 (Memory Management)
# David Brady

# General Makefile notes
#
#  $<: the name of the prerequisite of the rule
#  $@: the name of the target of the rule (the LHS of the ":")
#  $^: the RHS of the ":"

# Aliases
CC            = gcc
CFLAGS        = -g -Wall
TGTS          = oss userproc
SRCS          = oss.c userproc.c semops.c writelog.c sigcheck.c adv_clock.c
OBJS          = $(SRCS:.c=.o)
COMMOBJ       = semops.o writelog.o sigcheck.o adv_clock.o

all:          $(TGTS)
.PHONY:		all

# Suffix replacement rule for building all object files
.c.o:
	$(CC) -c $(CFLAGS) -o $@ $<

oss:          oss.o $(COMMOBJ)
	$(CC) -o $@ $^

userproc:     userproc.o $(COMMOBJ)
	$(CC) -o $@ $^

.PHONY:       scrub clean 
scrub:
	rm -f $(TGTS)
clean:
	rm -f $(OBJS) *.log
