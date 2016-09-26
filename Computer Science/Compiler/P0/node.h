#ifndef NODE_H
#define NODE_H

#include <vector>
#include <string>

using namespace std;

typedef struct node {
	int level;							// Using level for the indentation purpose
	char letter;							// First letter of the word
    vector<string> words;			// Vector to store the words
    node *left;
    node *middle;
    node *right;
} TREE;

#endif

