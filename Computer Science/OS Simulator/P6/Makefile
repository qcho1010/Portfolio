CC = gcc
CFLAGS = -g

OSSO = oss.o
OSS = oss

UPO = uproc.o
UP = uproc


.SUFFIXES: .c .o

all: $(OSS) $(UP)

$(OSS): $(OSSO)
	$(CC) -o $@ $(OSSO)

$(UP): $(UPO)
	$(CC) -o $@ $(UPO)

.c.o:
	$(CC) -c -o $@ $<

clean:
	rm *.o $(UP) $(OSS) *.log

pclean:
	rm *.o rm *.log
