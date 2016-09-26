#include <iostream>
#include <algorithm>
#include "scanner.h"

//Key for storing alphabet lookup in array
struct alphabetKey {
    int key;
    int value;
};

//structure for holding a token map
typedef struct {
    int key;
    tokenID name;
}tkMap;

//State table corresponding to DFA
int stateTable[10][24] = {
        {5,6,6,7,3,3,3,3,3,3,4,4,4,4,4,4,4,4,4,1,2,0,-99},
        {1000,1000,1000,1000,1000,1000,1000,1000,1000,1000,1000,1000,1000,1000,1000,1000,1000,1000,1000,1,1000,1000,0},
        {1001,1001,1001,1001,1001,1001,1001,1001,1001,1001,1001,1001,1001,1001,1001,1001,1001,1001,1001,1001,2,1001,0},
        {1002,1002,1002,1002,1002,1002,1002,1002,1002,1002,1002,1002,1002,1002,1002,1002,1002,1002,1002,1002,1002,1002,0},
        {1003,1003,1003,1003,1003,1003,1003,1003,1003,1003,1003,1003,1003,1003,1003,1003,1003,1003,1003,1003,1003,1003,0},
        {9,9,9,1002,1002,1002,1002,1002,1002,1002,1002,1002,1002,1002,1002,1002,1002,1002,1002,1002,1002,1002,0},
        {1004,1004,1004,1004,1004,1004,1004,1004,1004,1004,1004,1004,1004,1004,1004,1004,1004,1004,1004,1004,1004,1004,0},
        {8,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2},
        {1004,1004,1004,1004,1004,1004,1004,1004,1004,1004,1004,1004,1004,1004,1004,1004,1004,1004,1004,1004,1004,1004,0},
        {1004,1004,1004,1004,1004,1004,1004,1004,1004,1004,1004,1004,1004,1004,1004,1004,1004,1004,1004,1004,1004,1004,0}
};

//used to look up characters (column in state table)
alphabetKey charLookup[19] = {
        {'=', 0}, {'<', 1}, {'>', 2}, {'!', 3}, {':', 4}, 
		{'+', 5}, {'-', 6}, {'*', 7}, {'/', 8}, {'%', 9}, 
		{'.', 10}, {'(', 11}, {')', 12}, {',', 13}, {'{', 14}, 
		{'}', 15}, {';', 16}, {'[', 17}, {']', 18}
};


//looks up column on state table
int colLookup(char lookAhead) {
    for (int i = 0; i < 19; i++) {
        if(charLookup[i].key == lookAhead) {
            return charLookup[i].value;
        }
    }

    if (isalpha(lookAhead)) {
        return 19;
    } else if (isdigit(lookAhead)) {
        return 20;
    } else if (isspace(lookAhead)) {
        return 21;
    } else if (lookAhead == EOF) {
        return 22;
    } else {
        return 23;
    }
}

//Used to define keywords (all line numbers default to 0, will be changed in scanner)
token keywordLookup[13] = {
        {START_tk, "START", 0},
        {FIN_tk, "FINISH", 0},
        {THEN_tk, "THEN", 0},
        {IF_tk, "IF", 0},
        {WHILE_tk, "WHILE", 0},
        {INT_tk, "INT", 0},
        {DO_TK, "DO", 0},
        {FREAD_tk, "FREAD", 0},
        {FPRINT_tk, "FPRINT", 0},
        {VOID_tk, "VOID", 0},
        {RETURN_tk, "RETURN", 0},
        {PROGRAM_tk, "PROGRAM", 0},
        {DUM_tk, "DUMMY", 0}
};
	
//lookup table for final states
tkMap tokenLookupTable[6] = {
        {-99,  EOF_tk},
        {1000, IDENT_tk},
        {1001, NUM_tk},
        {1002, OP_tk},
        {1003, DEL_tk},
        {1004, REL_tk}
};

//function to look up tokens based on state and instance
token tokenLookup(int val, string word) {
    token t;
    string upperCaseWord;
    upperCaseWord.append(word);

    std::transform(upperCaseWord.begin(), upperCaseWord.end(), upperCaseWord.begin(), ::toupper);
	
    for (int i = 0; i < 6; i++) {
        if (val == 1000) {
            for (int j = 0; j < 13; j++) {
                if (keywordLookup[j].name == upperCaseWord) {
                    t.tokenId = keywordLookup[j].tokenId;
                    t.name = word;
                    t.lineNum = 7;
                }
            }
        }

        if (tokenLookupTable[i].key == val) {
            t.tokenId = tokenLookupTable[i].name;
            t.name = word;
            t.lineNum = 6;
        }
    }

    return t;
}


//Method for scanning, calling scanner(FILE *fp, int &lineNum) will return one token at a time
token scanner(FILE *fp, int &lineNum) {
    int lookahead;
    int stateCol;
    int currState = 0, nextState = 0;
    string word;
    token t;

    //if we're not at a final state or an error
    while (currState < 1000 && currState >= 0) {
        lookahead = fgetc(fp);
        //filter comments
        if(lookahead == '#') {
            cout << "comment\n";
            while (lookahead != '\n') {
                lookahead = fgetc(fp);
            }
            lineNum++;
        }

        //get the next state
        stateCol = colLookup(lookahead);
        nextState = stateTable[currState][stateCol];
        //if it's a final state or EOF
        if (nextState >= 1000 || nextState == -99) {
            if (lookahead == '\n') {
                lineNum++;
            }

            //if EOF
            if (nextState == -99) {
                ungetc(lookahead, fp);
                t.tokenId = EOF_tk;
                t.lineNum = lineNum;
                t.name = "EOF";
                return t;
            } else if (nextState >= 1000) { // if final state
                t = tokenLookup(nextState, word);
                t.lineNum = lineNum;
                ungetc(lookahead, fp);
                return t;
            } else { //error
                cout << "Error: Line " << lineNum << " value: " << static_cast<char>(lookahead) << "\n";
                t.tokenId = ERR_tk;
                t.lineNum = lineNum;
                t.name = "Error";
                return t;
            }
        } else { //keep reading in characters if not a final state, EOF, or error
            char value = static_cast<char>(lookahead);
            if (!isspace(value)) {
                word += value;
            }
            //handle equals and bang equals
            if (nextState == 6){
                int lookahead2 = fgetc(fp);
				if (lookahead2 == '>') {
                    word += static_cast<char>(lookahead2);
                } 
				if (lookahead2 == '<') {
                    word += static_cast<char>(lookahead2);
                } 
            } 
            currState = nextState;
        }

    }
    //in case there is an undocumented error with the scanner
    t.tokenId = ERR_tk;
    t.lineNum = lineNum;
    t.name = "Scanner didn't do anything";
    return t;
}
