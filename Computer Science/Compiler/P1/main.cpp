#include <iostream>
#include <fstream>
#include "driver4scanner.h"

using namespace std;

FILE *fp;

int main(int argc, char *argv[]) {
    string fileName;

    //If a filename was given
    if (argc == 2) {
        fileName = argv[1];
        fileName.append(".4280");

        fp = fopen(fileName.c_str(), "r");
    } else if (argc == 1) { //read from keyboard and put in temp file "input.4280"
        string input;
        ofstream tempFile;

        fileName = "input.4280";
        tempFile.open(fileName.c_str());

        cout << "Please enter alphanumeric character strings and press ctrl+d when finished.\n";
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

    //Call driver
    driver4Scanner(fp);

    return 0;
}
