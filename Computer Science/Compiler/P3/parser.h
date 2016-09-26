#ifndef PARSER_H
#define PARSER_H

#include <stdio.h>
#include "node.h"

extern FILE* fp;
extern int lineNum;

node_t* parser();
node_t* prog_f();
node_t* funs_f();
node_t* block_f();
node_t* vars_f();
node_t* mvars_f();
node_t* expr_f();
node_t* T_f();
node_t* F_f();
node_t* R_f();
node_t* stats_f();
node_t* mStat_f();
node_t* stat_f();
node_t* in_f();
node_t* out_f();
node_t* if_f();
node_t* loop_f();
node_t* assign_f();
node_t* RO_f();
void error(string s);
node_t *getNode(string s);
	
#endif
