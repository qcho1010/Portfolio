work: main.o buildTree.o traversals.o
	g++ main.o buildTree.o traversals.o -o work

main.o: main.cpp
	g++ -c main.cpp

buildTree.o: buildTree.cpp
	g++ -c buildTree.cpp

traversals.o: traversals.cpp
	g++ -c traversals.cpp

clean:
	rm -rf *.o work