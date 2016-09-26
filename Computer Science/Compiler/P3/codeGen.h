#ifndef CODEGEN_H
#define CODEGEN_H

#include "node.h"

void initOutFile(FILE* of);
void genCode(node_t* node);

#endif
