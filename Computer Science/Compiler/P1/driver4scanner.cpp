#include "driver4scanner.h"
using namespace std;

//token names for lookup with token enumeration
string tokenNames[] = {"Identifier", "Number", "START keyword", "FINISH keyword",
                       "THEN keyword", "IF keyword", "WHILE keyword", "INT keyword", "DO keyword", "FREAD keyword",
                       "FPRINT keyword", "VOID keyword", "RETURN keyword", "PROGRAM keyword", "DUMMY keyword",
                       "Relational Operator", "Other Operator", "Delimeter", "End of File", "Error"};


//function to print tokens
void printToken(token t) {
        cout << "Line Num: " << t.lineNum << ", Token ID: " << tokenNames[t.tokenId] << ", Token Instance: " << t.name << "\n";
}

//driver called by main
void driver4Scanner(FILE *fp) {
    int lookahead;
    int lineNum = 1;
    while((lookahead = fgetc(fp)) != EOF) {
        ungetc(lookahead, fp);
        token t = scanner(fp, lineNum);
        if(t.tokenId != ERR_tk) {
            printToken(t);
        } else {
            printToken(t);
            return;
        }

    }

    fclose(fp);

}
