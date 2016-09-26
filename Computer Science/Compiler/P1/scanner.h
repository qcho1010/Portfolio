#ifndef SCANNER_H
#define SCANNER_H

#include <stdio.h>
#include <ctype.h>
#include <string>

using namespace std;

//Token enumeration (corresponding to array indicies)
enum tokenID {IDENT_tk, NUM_tk, START_tk, FIN_tk, THEN_tk,  IF_tk, WHILE_tk, INT_tk, DO_TK, FREAD_tk,
    FPRINT_tk, VOID_tk, RETURN_tk, PROGRAM_tk, DUM_tk, REL_tk, OP_tk, DEL_tk, EOF_tk, ERR_tk};

//the token structure
struct token {
    tokenID tokenId;
    string name;
    int lineNum;
};

token scanner(FILE *fp, int &lineNum);


#endif
