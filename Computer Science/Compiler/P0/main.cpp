#include <iostream>
#include "node.h"
#include "buildTree.h"
#include "traversals.h"

using namespace std;

int main(int argc, char* argv[]) {
	string fileName, input;

	if(argc == 1) {		// file name isn't given, build data structure from the keyboard
        ofstream tempFile;
		fileName = "data.input";
		tempFile.open(fileName.c_str());
		printf("Info: No file given, using stdin. Ctrl + D to end input.\n");
		while (cin >> input) //read input from keyboard
            tempFile << input << "\n";
		tempFile.close();
	} else if (argc == 2) { // file name is given, attach the extension .input
        fileName = argv[1];
        fileName.append(".input");
	} else {
		cout << "Error: invalid input" << endl;
        return 1;
    }

	TREE *root = buildTree(fileName);
	
	cout<<"\nPreorder"<<endl;
	preOrder(root);
	cout<<"\nInorder"<<endl;
	inOrder(root);
	cout<<"\nPostorder"<<endl;
	postOrder(root);
}
