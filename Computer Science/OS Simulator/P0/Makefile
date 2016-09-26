all: doenv
doenv: doenv.o
	gcc doenv.o -o doenv
doenv.o: doenv.c
	gcc -c doenv.c
clean:
	rm -rf *o doenv
