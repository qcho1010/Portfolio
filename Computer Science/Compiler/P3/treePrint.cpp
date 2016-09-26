#include <iostream>
#include "treePrint.h"

//token names for lookup with token enumeration
string tokenNames[] = {"Identifier", "Number", "START keyword", "FINISH keyword",
                       "THEN keyword", "IF keyword", "WHILE keyword", "INT keyword", "DO keyword", "FREAD keyword",
                       "FPRINT keyword", "VOID keyword", "RETURN keyword", "PROGRAM keyword", "DUMMY keyword",
                       "Relational Operator", "Other Operator", "Delimeter", "End of File", "Error"};
					   
void printTree(node_t *root, int level) {
     if (root != NULL) { 
        for (int i = 0; i < level; i++) {
            cout << "  ";
        }
        level++;
        cout << root->label << "\t";

        token token = root->token_t;
        if (token.name != "") {
            cout <<  "Token ID: " + tokenNames[token.tokenId] + " Instance: " + token.name << endl;
        }
        cout << "\n";

        printTree(root->child1, level);
        printTree(root->child2, level);
        printTree(root->child3, level);
        printTree(root->child4, level);
        printTree(root->child5, level);
    } else {
		return;
	}
}