#ifndef BUILDTREE_H
#define BUILDTREE_H

#include <fstream>
#include <string.h>
#include "node.h"

using namespace std;

TREE *buildTree(string);
TREE *createNode (string);
TREE *insertNode (TREE *, string);

#endif
