#include <iostream>
#include <vector>
#include <sstream>
#include <stdlib.h>
#include "codeGen.h"

vector<string> temp; //temp vars
vector<string> scope; //scope of vars
int labelCt = 0; //counter for labels
int varCt = 0; //counter for vars
int startOfScope = 0; //scope

FILE *outFile;

void initOutFile(FILE *of) {
    outFile = of;
}
 
// push a var onto the scope
 void pushScope(token tk) {
    for (int i = startOfScope; i < scope.size(); i++) {
        if (scope[i] == tk.name) {
            cout << "variable " << tk.name << " on " << tk.lineNum << " is already defined for this scope\n";
            exit(0);
        }
    }

    scope.push_back(tk.name);
    fprintf(outFile, static_cast<string>("PUSH\n").c_str());
}

// pop a var off the scope
void popScope(int scopeStart) {
    for (int i = scope.size(); i > scopeStart; i--) {
        scope.pop_back();
        fprintf(outFile, static_cast<string>("POP\n").c_str());
    }
}


// search for a var in the scope
int find(string var) {
    for (int i = scope.size() - 1; i > -1; i--) {
        if (scope[i] == var) {
            return scope.size() - 1 - i;
        }
    }

    return -1;
}

// print the scope
void printScope() {
    for (int i = scope.size() - 1; i >= 0; i--) {
        cout << scope[i] << endl;
    }
}

// handle errors with vars in particular
void errorWithVar(token tk) {
    cout << "Variable " << tk.name << " on line " << tk.lineNum << " is not defined.\n";
    exit(0);
}

// create a new temporary variable
string newTemp() {
    std::ostringstream ostringstream1;
    ostringstream1 << "T" << varCt++;
    temp.push_back(ostringstream1.str());
    return ostringstream1.str();
}

// create a new label
string newLabel() {
    std::ostringstream ostringstream1;
    ostringstream1 << "L" << labelCt++;
    return ostringstream1.str();
}

// genCode Generate the output file based on what node we're visiting
// big ugly if else if else if... because I'm using strings instead of enums
void genCode(node_t* node) {
	// printf("START");
    if (node == NULL) {
        return;
    } else { //process node
        string label = node->label;

        if (label == "<program>") {
            // recurse on "PROGRAM"
            genCode(node->child1);
            genCode(node->child2);
            genCode(node->child3);
            genCode(node->child4);

            fprintf(outFile, static_cast<string>("STOP\n").c_str());

            // add non-temp vars to file
            for (int i = 0; i < scope.size(); i++) {
                fprintf(outFile, static_cast<string>(scope[i] + " 0\n").c_str());
            }

            // add temp vars to file
            for (int i = 0; i < temp.size(); i++) {
                fprintf(outFile, static_cast<string>(temp[i] + " 0\n").c_str());
            }

            // Pop everything off the scope
            popScope(startOfScope);
        } else if (label == "<var>") {			//<vars>          ->     empty | INT Identifier <mvars> .
            startOfScope = scope.size();
            if (node -> child1 != NULL && node->child2 != NULL) { //avoid nasty null pointers
                pushScope(node->child2->token_t); //push the var onto the scope
            }

            genCode(node->child1);
            genCode(node->child2);
            genCode(node->child3);
            genCode(node->child4);
            genCode(node->child5);
        } else if (label == "<mvars>") {			//<mvars>     ->     empty | + Identifier <mvars>
            if (node->child1 != NULL) {
                pushScope(node->child1->token_t); ///push the var onto the scope
            }
            genCode(node->child2);
        } else if (label == "<block>") {		//<block>       ->     START <vars> <stats> FINISH
            int start = scope.size(); //set the size of the scope when the block node is first seen

            genCode(node->child1);
            genCode(node->child2);
            genCode(node->child3);
            genCode(node->child4);
            genCode(node->child5);

            popScope(start); //pop the scope back to the size of the scope at the start of the block
        }  else if (label == "<in>") {		//<in>              ->      FREAD Identifier .
            string varInstance = node->child1->token_t.name; //the var
            int d = find(varInstance); //see if it's in the scope already
            if (d == -1) {
                errorWithVar(node->child1->token_t); //error if not in the scope
            }

            string tempVar = newTemp(); //new temp variable

            // write to target
            fprintf(outFile, "READ %s\n", tempVar.c_str());
            fprintf(outFile, "LOAD %s\n", tempVar.c_str());
            fprintf(outFile, "STACKW %d\n", d);

            genCode(node->child1);
            genCode(node->child2);
            genCode(node->child3);
            genCode(node->child4);
            genCode(node->child5);
        } else if (label == "<out>") {		//<out>            ->      FPRINT (<expr>)  .
            genCode(node->child1); //load the value to be written out into the accumulator
            string tempVar = newTemp(); //new temp variable
            
			// write to target
            fprintf(outFile, "STORE %s\n", tempVar.c_str());
            fprintf(outFile, "WRITE %s\n", tempVar.c_str());
        } else if (label == "<expr>") {		//<expr>        ->      <T> * <expr> | <T> / <expr> | <T>
            if (node->child3 != NULL && node->child2->label == "*") {
                genCode(node->child3); //expr node
                string tempVar = newTemp();
                fprintf(outFile, "STORE %s\n", tempVar.c_str());
                genCode(node->child1); //T node
                fprintf(outFile, "MULT %s\n", tempVar.c_str());
            } else if (node->child3 != NULL && node->child2->label == "/") {
                genCode(node->child3); //expr node
                string tempVar = newTemp();
                fprintf(outFile, "STORE %s\n", tempVar.c_str());
                genCode(node->child1); //T node
                fprintf(outFile, "DIV %s\n", tempVar.c_str());
            } else {
                genCode(node->child1);
            }

        } else if (label == "<T>") {		//<T>              ->      <F> + <T> | <F> - <T> | <F>
            if (node->child2 != NULL && node->child2->label == "+") {
                genCode(node->child3); //T node
                string tempVar = newTemp();
                fprintf(outFile, "STORE %s\n", tempVar.c_str());
                genCode(node->child1); //F node
                fprintf(outFile, "ADD %s\n", tempVar.c_str());
            } else if (node->child2 != NULL && node->child2->label == "-") {
                genCode(node->child3); //T node
                string tempVar = newTemp();
                fprintf(outFile, "STORE %s\n", tempVar.c_str());
                genCode(node->child1); //F node
                fprintf(outFile, "SUB %s\n", tempVar.c_str());
            } else
                genCode(node->child1);
        } else if (label == "<F>") {		//<F>              ->      - <F> | <R>
            if (node->child1->label == "-") {
                genCode(node->child2);
                fprintf(outFile, "MULT -1\n");
            } else
                genCode(node->child1);
        } else if (label == "<R>") {		//<R>              ->      (<expr>) | Identifier | Number
            cout << "<R> is " << node->child1->label << endl;
            if (node->child1->label == "IDENTIFIER") { //if we have an identifier
                cout << "Found Identifier " << node->child1->token_t.name << endl;
                int d = find(node->child1->token_t.name);
                if (d == -1)
                    errorWithVar(node->child1->token_t);
                fprintf(outFile, "STACKR %d\n", d);
            } else if (node->child1->label == "NUMBER") { //if we have a number
                cout << "loading a number " << node->child1->token_t.name << endl;
                fprintf(outFile, "LOAD %s\n", node->child1->token_t.name.c_str());
            } else {
                genCode(node->child1); //<expr>
            }
        } else if (label == "<assign>") {		//<assign>       ->      Identifier := <expr> .
            genCode(node->child1); //get the value to assign to the var
            int d = find(node->child1->token_t.name); ///see if the var is in the scope
            if (d == -1)
                errorWithVar(node->child1->token_t); //error if var is not in the scope
            fprintf(outFile, "STACKW %d\n", d);
        } else if (label == "<loop>") {		//<loop>          ->      WHILE [ <expr> <RO> <expr> ] <block>
            string RO = node->child2->child1->label; //get the relational operator instance

            string tempVar = newTemp(); //new temp variable
            string startLabel = newLabel(); //starting label for loop
            string endLabel = newLabel(); //ending label for loop

            fprintf(outFile, "%s: ", startLabel.c_str()); //set start label
			
            // get test condition	
            genCode(node->child3);
            fprintf(outFile, "STORE %s\n", tempVar.c_str());
            genCode(node->child1);
            fprintf(outFile, "SUB %s\n", tempVar.c_str()); //accumulator now holds the difference between the args

            // determine which BR command to write to target
            if (RO == ">") {
                fprintf(outFile, "BRZNEG %s\n", endLabel.c_str());
            } else if (RO == "<") {
                fprintf(outFile, "BRZPOS %s\n", endLabel.c_str());
            } else if (RO == ">>") {
                fprintf(outFile, "BRNEG %s\n", endLabel.c_str());
            } else if (RO == "<<") {
                fprintf(outFile, "BRPOS %s\n", endLabel.c_str());
            } else if (RO == "==") {
                fprintf(outFile, "BRPOS %s\n", endLabel.c_str());
                fprintf(outFile, "BRNEG %s\n", endLabel.c_str());
            } else if (RO == "!=") {
                fprintf(outFile, "BRZERO %s\n", endLabel.c_str());
            }

            genCode(node->child4); //get the block for the loop
            fprintf(outFile, "BR %s\n", startLabel.c_str()); //jump back to loop beginning

            fprintf(outFile, "%s: NOOP\n", endLabel.c_str()); //print the out label
        } else if (label == "<if>") {		//<if>               ->      IF [<expr> <RO> <expr>]  DO <block> 
            // string RO = node->child2->child1->label; //get the relational operator instance
            
			 // get test condition	
			// genCode(node->child3);
            // string tempVar = newTemp(); //new temp variable
            // fprintf(outFile, "STORE %s\n", tempVar.c_str());
            // genCode(node->child1);
            // fprintf(outFile, "SUB %s\n", tempVar.c_str()); //accumulator now holds the difference

            // determine which BR command to write to target
            // string Label = newLabel();
            // if (RO == ">") {
                // fprintf(outFile, "BRZNEG %s\n", Label.c_str());
            // } else if (RO == "<") {
                // fprintf(outFile, "BRZPOS %s\n", Label.c_str());
            // } else if (RO == ">>") {
                // fprintf(outFile, "BRNEG %s\n", Label.c_str());
            // } else if (RO == "<<") {
                // fprintf(outFile, "BRPOS %s\n", Label.c_str());
            // } else if (RO == "==") {
                // fprintf(outFile, "BRPOS %s\n", Label.c_str());
                // fprintf(outFile, "BRNEG %s\n", Label.c_str());
            // } else if (RO == "!=") {
                // fprintf(outFile, "BRZERO %s\n", Label.c_str());
            // }

            // genCode(node->child4);
            // fprintf(outFile, "%s: NOOP\n", Label.c_str());
			
			string RO = node->child2->child1->label; //get the relational operator instance

            string tempVar = newTemp(); //new temp variable
            string startLabel = newLabel(); //starting label for loop
            string endLabel = newLabel(); //ending label for loop

            fprintf(outFile, "%s: ", startLabel.c_str()); //set start label
			
            // get test condition	
            genCode(node->child3);
            fprintf(outFile, "STORE %s\n", tempVar.c_str());
            genCode(node->child1);
            fprintf(outFile, "SUB %s\n", tempVar.c_str()); //accumulator now holds the difference between the args

            // determine which BR command to write to target
            if (RO == ">") {
                fprintf(outFile, "BRZNEG %s\n", endLabel.c_str());
            } else if (RO == "<") {
                fprintf(outFile, "BRZPOS %s\n", endLabel.c_str());
            } else if (RO == ">>") {
                fprintf(outFile, "BRNEG %s\n", endLabel.c_str());
            } else if (RO == "<<") {
                fprintf(outFile, "BRPOS %s\n", endLabel.c_str());
            } else if (RO == "==") {
                fprintf(outFile, "BRPOS %s\n", endLabel.c_str());
                fprintf(outFile, "BRNEG %s\n", endLabel.c_str());
            } else if (RO == "!=") {
                fprintf(outFile, "BRZERO %s\n", endLabel.c_str());
            }

            genCode(node->child4); //get the block for the loop
            // fprintf(outFile, "BR %s\n", startLabel.c_str()); //jump back to loop beginning

            fprintf(outFile, "%s: NOOP\n", endLabel.c_str()); //print the out label
        } else { //default is just to recurse
            genCode(node->child1);
            genCode(node->child2);
            genCode(node->child3);
            genCode(node->child4);
            genCode(node->child5);
        }
    }
}
