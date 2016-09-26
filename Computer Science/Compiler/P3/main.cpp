#include <iostream>
#include <fstream>
#include <string.h>
#include "parser.h"
#include "treePrint.h"
#include "codeGen.h"


using namespace std;

int main(int argc, char *argv[]) {
    string fileName, targName;
    int level = 0;
	
    //If a filename was given
    if (argc == 2) {
        fileName = argv[1];
        fileName.append(".4280");

        fp = fopen(fileName.c_str(), "r");
    } else if (argc == 1) { 
        string input;
        ofstream tempFile;

        fileName = "input.4280";
        tempFile.open(fileName.c_str());

		printf("Info: No file given, using stdin. Ctrl + D to end input.\n");
        while (cin >> input) { //read input from keyboard
            //Add word to file
            tempFile << input << "\n";
        }

        tempFile.close();

        fp = fopen(fileName.c_str(), "r");
    } else {
        cout << "No valid input given. Exiting... \nPlease try to run again with the format 'testScanner [filename]'\n";
        return 1;
    }

    //Parse input
    node_t *parseTree = parser();
	
    //Print parse tree
    printTree(parseTree, level);
	
    // create out file and give it to the code generator
    if (fileName.compare("input.4280") == 0) {
        targName = "keyboard.asm";
    } else {
        targName = strcat(argv[1], ".asm");
    }
    FILE *outFile = fopen(targName.c_str(), "w");
    initOutFile(outFile);

    //generate target
    genCode(parseTree);
	
    fclose(outFile);
	
    fclose(fp);
	
    return 0;
}
