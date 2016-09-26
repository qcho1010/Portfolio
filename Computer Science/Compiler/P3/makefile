comp: main.o scanner.o parser.o codeGen.o treePrint.o
	g++ main.o scanner.o parser.o codeGen.o treePrint.o -o comp

main.o: main.cpp
	g++ -c main.cpp

scanner.o: scanner.cpp
	g++ -c scanner.cpp

parser.o: parser.cpp
	g++ -c parser.cpp

codeGen.o: codeGen.cpp
	g++ -c codeGen.cpp

treePrint.o: treePrint.cpp
	g++ -c treePrint.cpp

clean:
	rm -rf *.o comp
