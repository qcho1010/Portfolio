testScanner: parser.o scanner.o treePrint.o main.o
	g++ parser.o treePrint.o scanner.o main.o -o testScanner

scanner.o: scanner.cpp
	g++ -c scanner.cpp

treePrint.o: treePrint.cpp
	g++ -c treePrint.cpp
	
parser.o: parser.cpp
	g++ -c parser.cpp

main.o: main.cpp
	g++ -c main.cpp

clean:
	rm -rf *.o testScanner
