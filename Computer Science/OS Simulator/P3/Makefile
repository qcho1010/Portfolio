CC = cc
COPS =
LOPS = -x -u
LINT = lint

all: swim_mill fish pellet

swim_mill: swim_mill.c display.c
	$(CC) $(COPS) -o swim_mill swim_mill.c display.c -lm

fish: fish.c display.c
	$(CC) $(COPS) -o fish fish.c display.c -lm

pellet: pellet.c display.c
	$(CC) $(COPS) -o pellet pellet.c display.c -lm

lintall: lintswim_mill lintfish lintpellet

lintswim_mill:
	$(LINT) $(LOPS) swim_mill.c

lintfish:
	$(LINT) $(LOPS) fish.c

lintpellet:
	$(LINT) $(LOPS) pellet.c

clean:
	rm -f *.o core lintswim_mill lintfish lintpellet
