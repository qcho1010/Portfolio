#include <iostream>
#include <stdlib.h>
#include "parser.h"

token tk;
FILE *fp = NULL;
int lineNum = 0;
int level = 0;

// Parser, returns parse tree
node_t* parser() {
    node_t *treep;
    tk = scanner(fp, lineNum);
    // tk = scanner(fp, lineNum);
    treep = prog_f();
    // treep = if_f();

    cout << "Parse OK\n";
    return treep;
}


//<program>  ->     <vars> <funs>  DO  <block> 
node_t* prog_f() {
    node_t *p = getNode("<program>");
	
	p->child1 = vars_f();
    p->child2 = funs_f();
	
	if(tk.tokenId == DO_TK) { // DO
        p->child3 = getNode("DO");
        tk = scanner(fp, lineNum);
        p->child4 = block_f();
        return p;
    } else {
        error("Got token " + tk.name + ", expected DO token");
    }

    return p;
}

//<funs>        ->    empty | DUMMY Identifier <block> RETURN Identifier . <funs> 
node_t* funs_f() {
    node_t *p = getNode("<funs>");

	if (tk.tokenId == DO_TK) {
		return p;
	} else if (tk.tokenId == DUM_tk) {
		p->child1 = getNode("DUMMY"); // DUMMY
		tk = scanner(fp, lineNum);
		if(tk.tokenId == IDENT_tk) { // IDENTIFIER
			p->child2 = getNode("Identifier");
			p->child2->token_t = tk;
			tk = scanner(fp, lineNum);
			p->child3 = block_f();
			if(tk.tokenId == RETURN_tk) { // RETURN
				p->child4 = getNode("RETURN");
				tk = scanner(fp, lineNum);				
				if(tk.tokenId == IDENT_tk) { // IDENTIFIER
					p->child5 = getNode("Identifier");
					p->child5->token_t = tk;
					tk = scanner(fp, lineNum);
					if (tk.tokenId == DEL_tk && tk.name == ".") { // .
						tk = scanner(fp, lineNum);
						p->child6 = funs_f();
						return p;
					} else {
					error("Got token " + tk.name + ", expected . token");
					}
				} else {
					error("Got token " + tk.name + ", expected IDENTIFIER token");
				}
			} else {
				error("Got token " + tk.name + ", expected RETURN token");
			}
		} else {
			error("Got token " + tk.name + ", expected IDENTIFIER token");
		}
	} else {
		error("Got token " + tk.name + ", expected empty or DUMMY token");
	}
	return p;
}

//<block>       ->     START <vars> <stats> FINISH
node_t* block_f() {
    node_t *p = getNode("<block>");

    if (tk.tokenId == START_tk && tk.name == "START") { // START
        tk = scanner(fp, lineNum);
        p->child1 = vars_f();
        p->child2 = stats_f();
        if (tk.tokenId == FIN_tk && tk.name == "FINISH") { // FINISH
            tk = scanner(fp, lineNum);
            return p;
        } else {
            error("Got token " + tk.name + ", expected FINISH token");
        }
    } else {
        error("Got token " + tk.name + ", expected START token");
    }

    return p;
}

//<vars>          ->     empty | INT Identifier <mvars> .
node_t* vars_f() {
    node_t *p = getNode("<var>");

    if(tk.tokenId == DO_TK || tk.tokenId == DUM_tk || tk.tokenId == FREAD_tk || tk.tokenId == FPRINT_tk ||
            tk.tokenId == START_tk || tk.tokenId == IF_tk || tk.tokenId == WHILE_tk || tk.tokenId == IDENT_tk ) { // empty
        return p;
    } else if(tk.tokenId == INT_tk) { // INT
        p->child1 = getNode("INT");
        p->child1->token_t = tk;
        tk = scanner(fp, lineNum);
        if(tk.tokenId == IDENT_tk) { // IDENTIFIER
            p->child2 = getNode("IDENTIFIER");
            p->child2->token_t = tk;
            tk = scanner(fp, lineNum);
            p->child3 = mvars_f();
            if (tk.tokenId == DEL_tk && tk.name == ".") { // .
                tk = scanner(fp, lineNum);
                return p;
            } else {
                error("Got token " + tk.name + ", expected . token");
            }
        } else {
            error("Got token " + tk.name + ", expected IDENTIFIER token");
        }
    } else {
        error("Got token " + tk.name + ", expected empty or INT token");
    }
    return p;
}

//<mvars>     ->     empty | + Identifier <mvars>
node_t* mvars_f() {
    node_t *p = getNode("<mvars>");

    if (tk.tokenId == DEL_tk && tk.name == ".") { // empty
        return p;
    } else if (tk.tokenId == OP_tk && tk.name == "+") { // +
		// p->child1 = getNode("+");
		tk = scanner(fp, lineNum);
		if(tk.tokenId == IDENT_tk) { // IDENTIFIER
			p->child1 = getNode("Identifier");
			p->child1->token_t = tk;
			tk = scanner(fp, lineNum);
			p->child2 = mvars_f();
			return p;
		} else {
			error("Got token " + tk.name + ", expected IDENTIFIER token");
		}
    } else {
		error("Got token " + tk.name + ", expected empty or + token");
	}

    return p;
}

//<expr>        ->      <T> * <expr> | <T> / <expr> | <T>
node_t* expr_f() {
    node_t *p = getNode("<expr>");

    p->child1 = T_f();
    if (tk.tokenId == OP_tk && tk.name == "*") { // *<expr>
        p->child2 = getNode("*");
        tk = scanner(fp, lineNum);
        p->child3 = expr_f();
        return p;
    } else if(tk.tokenId == OP_tk && tk.name == "/") { // /<expr>
        p->child2 = getNode("/");
        tk = scanner(fp, lineNum);
        p->child3 = expr_f();
        return p;
    } else { // <T>
        return p;
    }
}

//<T>              ->      <F> + <T> | <F> - <T> | <F>
node_t* T_f() {
    node_t *p = getNode("<T>");

    p->child1 = F_f();
    if(tk.tokenId == OP_tk && tk.name == "+") { // +<T>
        p->child2 = getNode("+");
        tk = scanner(fp, lineNum);
        p->child3 = T_f();
        return p;
    } else if(tk.tokenId == OP_tk && tk.name == "-") { // -<T>
        p->child2 = getNode("-");
        tk = scanner(fp, lineNum);
        p->child3 = T_f();
        return p;
    } else { //<F>
        return p;
    }
}

//<F>              ->      - <F> | <R>
node_t* F_f() {
    node_t *p = getNode("<F>");

    if(tk.tokenId == OP_tk && tk.name == "-") { // -<F>
        p->child1 = getNode("-");
        tk = scanner(fp, lineNum);
        p->child2 = F_f();
        return p;
    } else if((tk.tokenId == DEL_tk && tk.name == "(") || tk.tokenId == IDENT_tk || tk.tokenId == NUM_tk) { // <R>
        p->child1 = R_f();
        return p;
    } else {
        error("Got token " + tk.name + " expected (, ID, NUM, or - token");
    }

    return p;
}

//<R>              ->      (<expr>) | Identifier | Number
node_t* R_f() {
    node_t *p = getNode("<R>");

    if (tk.tokenId == DEL_tk && tk.name == "(") { // (
        tk = scanner(fp, lineNum);
        p->child1 = expr_f();
        if (tk.tokenId == DEL_tk && tk.name == ")") { // )
            tk = scanner(fp, lineNum);
            return p;
        }
    } else if (tk.tokenId == IDENT_tk) { // IDENTIFIER
        p->child1 = getNode("IDENTIFIER");
        p->child1->token_t = tk;
        tk = scanner(fp, lineNum);
        return p;
    } else if (tk.tokenId == NUM_tk) { // NUMBER
        p->child1 = getNode("NUMBER");
        p->child1->token_t = tk;
        tk = scanner(fp, lineNum);
        return p;
    } else {
        error("Got token " + tk.name + ", expected (, IDENTIFIER, or NUMBER token");
    }

    return p;
}

//<stats>         ->      <stat>  <mStat>
node_t* stats_f() {
    node_t *p = getNode("<stats>");

    p->child1 = stat_f();
    p->child2 = mStat_f();
    return p;
}

//<mStat>       ->      empty | <stat>  <mStat>
node_t* mStat_f() {
    node_t *p = getNode("<mStat>");

    if (tk.tokenId == FIN_tk && tk.name == "FINISH") { // empty
        return p;
    } else {
        p->child1 = stat_f();
        p->child2 = mStat_f();
        return p;
    }
}

//<stat>           ->      <in> | <out> | <block> | <if> | <loop> | <assign>
node_t* stat_f() {
    node_t *p = getNode("<stat>");

    if (tk.tokenId == FREAD_tk) { // <in>
        p->child1 = getNode("FREAD");
        tk = scanner(fp, lineNum);
        p->child2 = in_f();
        return p;
    } else if (tk.tokenId == FPRINT_tk) { // <out>
        p->child1 = getNode("FPRINT");
        tk = scanner(fp, lineNum);
        p->child2 = out_f();
        return p;
    } else if (tk.tokenId == START_tk && tk.name == "START") { // <block>
        tk = scanner(fp, lineNum);
        p->child1 = block_f();
        return p;
    } else if (tk.tokenId == IF_tk) { // <if>
        p->child1 = getNode("IF");
        tk = scanner(fp, lineNum);
        p->child2 = if_f();
        return p;
    } else if (tk.tokenId == WHILE_tk) { // <loop>
        p->child1 = getNode("WHILE");
        tk = scanner(fp, lineNum);
        p->child2 = loop_f();
        return p;
    } else if (tk.tokenId == IDENT_tk) { // <assign>
        p->child1 = assign_f();
        return p;
    } else {
        error("Got token " + tk.name + ", expected FREAD, FPRINT, START, IF, WHILE, or IDENTIFIER token");
    }

	
    return p;
}

//<in>              ->      FREAD Identifier .
node_t* in_f() {
    node_t *p = getNode("<in>");

    if (tk.tokenId == IDENT_tk) { // IDENTIFIER
        p->child1 = getNode("IDENTIFIER");
        p->child1->token_t = tk;
        tk = scanner(fp, lineNum);
        if (tk.tokenId == DEL_tk && tk.name == ".") { // .
            tk = scanner(fp, lineNum);
            return p;
        } else {
            error("Got token " + tk.name + ", expected . token");
        }
    } else {
        error("Got token " + tk.name + ", expected IDENTIFIER token");
    }

    return p;
}

//<out>            ->      FPRINT (<expr>)  .
node_t* out_f() {
    node_t *p = getNode("<out>");

	if (tk.tokenId == DEL_tk && tk.name == "(") { // (
        tk = scanner(fp, lineNum);
		p->child1 = expr_f();
		if (tk.tokenId == DEL_tk && tk.name == ")") { // )
			tk = scanner(fp, lineNum);
			if (tk.tokenId == DEL_tk && tk.name == ".") { // .
				tk = scanner(fp, lineNum);
				return p;
			} else {
				error("Got token " + tk.name + ", expected . token");
			}
		} else {
			error("Got token " + tk.name + ", expected ) token");
		}
	} else {
		error("Got token " + tk.name + ", expected ( token");
	}
    
    return p;
}


//<if>               ->      IF [<expr> <RO> <expr>]  DO <block>        
node_t* if_f() {
    node_t *p = getNode("<if>");

    if (tk.tokenId == DEL_tk && tk.name == "[") { // [
        tk = scanner(fp, lineNum);
        p->child1 = expr_f();
        p->child2 = RO_f();
        p->child3 = expr_f();
        if (tk.tokenId == DEL_tk && tk.name == "]") { // ]
            tk = scanner(fp, lineNum);
            if (tk.tokenId == DO_TK) {
                tk = scanner(fp, lineNum);
                p->child4 = block_f();
                return p;
            } else {
                error("Got token " + tk.name + ", expected DO token'");
            }
        } else {
            error("Got token " + tk.name + ", expected ] token");
        }
    } else {
        error("Got token " + tk.name + ", expected [ token");
    }

    return p;
}

//<loop>          ->      WHILE [ <expr> <RO> <expr> ] <block>
node_t* loop_f() {
    node_t *p = getNode("<loop>");

    if(tk.tokenId == DEL_tk && tk.name == "[") { // [
        tk = scanner(fp, lineNum);
        p->child1 = expr_f();
        p->child2 = RO_f();
        p->child3 = expr_f();
        if (tk.tokenId == DEL_tk && tk.name == "]") { // ]
            tk = scanner(fp, lineNum);
            p->child4 = block_f();
            return p;
        } else {
            error("Got token " + tk.name + ", expected ] token");
        }
    } else {
        error("Got token " + tk.name + ", expected [ token");
    }

    return p;
}

//<assign>       ->      Identifier : = <expr> .
node_t* assign_f() {
    node_t *p = getNode("<assign>");

	p->child1 = getNode("IDENTIFIER");
	p->child1->token_t = tk;
	tk = scanner(fp, lineNum);
	if (tk.name == ":") { // :
	tk = scanner(fp, lineNum);
        if (tk.name == "=") { // =
            p->child2 = getNode("=");
            tk = scanner(fp, lineNum);
            p->child3 = expr_f();
            if (tk.name == ".") { // .
                //don't need to put delimiters in the tree
                tk = scanner(fp, lineNum);
                return p;
            } else {
                error("Got token " + tk.name + ", expected . token");
            }
        } else {
            error("Got token " + tk.name + ", expected = token");
        }
	} else {
            error("Got token " + tk.name + ", expected : token");
	}
    return p;
}


//<RO>            ->      >> | << | == |  > | <  |  !=
node_t* RO_f() {
    node_t *p = getNode("<RO>");
    if(tk.tokenId == REL_tk) {
        if (tk.name == ">>") { // =>
            p->child1 = getNode(">>");
            tk = scanner(fp, lineNum);
            return p;
        } else if (tk.name == "<<") { //=<
            p->child1 = getNode("<<");
            tk = scanner(fp, lineNum);
            return p;
        } else if (tk.name == "==") { // ==
            p->child1 = getNode("==");
            tk = scanner(fp, lineNum);
            return p;
        } else if (tk.name == ">") { // >
            p->child1 = getNode(">");
            tk = scanner(fp, lineNum);
            return p;
        } else if (tk.name == "<") { // <
            p->child1 = getNode("<");
            tk = scanner(fp, lineNum);
            return p;
        } else if (tk.name == "!=") { // !=
            p->child1 = getNode("!=");
            tk = scanner(fp, lineNum);
            return p;
        }
    } else {
        error("Got token " + tk.name + ", expected >>, <<, ==, >, <, or != token");
    }
    return p;
}


void error(string s) {
    cout << s << "\t at line: " << lineNum << endl;
    exit(0);
}

node_t *getNode(string s) {
    node_t *node = new node_t;
    node->label = s;
	node->child1 = NULL;
	node->child2 = NULL;
	node->child3 = NULL;
	node->child4 = NULL;
	node->child5 = NULL;
    return node;
}