#include <iostream>
#include "buildTree.h"
#include "node.h"

using namespace std;

TREE *buildTree(string fileName) {
	TREE *root = NULL;
    char letter;
    string word;
    ifstream file(fileName.c_str());

    if (!file.is_open()) { 
        cout << "File " << fileName << " not found. Exiting...\n Please try to run again using 'run [filename]'\n";
        return NULL;
    }

	while (file >> word) { 
		for (int i = 0; i < word.size(); i++) {
			if(!isalpha(word.at((unsigned int) i))) {
				cout <<"Error: Invalid character found" <<endl;
				return NULL;
			}
		}
		root = insertNode(root, word);
	}
	file.close();
    return root;
}

TREE *insertNode (TREE *p, string word) {
	char letter = word.at(0);
	if (!p) {		// termination condition for recursive calling
		p = createNode(word);
	} else if (p->left && letter < p->letter &&  p->left->letter < letter) {		// insert middle, if left node is not empty, value is greater than left, but less than its node's value.
		p->middle = insertNode(p->middle, word);
		p->middle->level = p->level + 1;
	} else if (letter < p->letter) {		// insert left, if left node is empty value is less than its node's value.
		p->left = insertNode(p->left, word);
		p->left->level = p->level + 1;
	} else if (letter > p->letter) {		// insert right, if value is strickly greater than its node's value.
		p->right = insertNode(p->right, word);
		p->right->level = p->level + 1;
	} else if (letter == p->letter) {
		p->words.push_back(word);
	}
	return p;
}

TREE *createNode (string word) {
    TREE *temp = new TREE;
	temp->left = NULL;
	temp->middle = NULL;
	temp->right = NULL;
	temp->level = 0;
	temp->letter = word.at(0);
    temp->words.push_back(word);
    return temp;
}
