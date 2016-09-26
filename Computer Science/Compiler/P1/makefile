testScanner: driver4scanner.o scanner.o main.o
	g++ driver4scanner.o scanner.o main.o -o testScanner 

scanner.o: scanner.cpp
	g++ -c scanner.cpp

driver4scanner.o: driver4scanner.cpp
	g++ -c driver4scanner.cpp

main.o: main.cpp
	g++ -c main.cpp

clean:
	rm -rf *.o testScanner
