#include <iostream>
#include "traversals.h"

void preOrder(TREE *p) {
    if (p == NULL)
		return;
    else {
		printFormat(p);
        preOrder(p->left);
        preOrder(p->middle);
        preOrder(p->right);
    }
}

void inOrder(TREE *p) {
    if (p == NULL)
		return;
    else {
        inOrder(p->left);
        inOrder(p->middle);
		printFormat(p);
        inOrder(p->right);
    }
}

void postOrder(TREE *p) {
    if (p == NULL)
		return;
    else {
        postOrder(p->left);
        postOrder(p->middle);
        postOrder(p->right);
		printFormat(p);
    }
}

void printFormat(TREE *p) {
	for (int i = 0; i < p->level; i++) 
		cout <<" ";
	cout << p->letter<<" : ";
	for (int i = 0; i < (int) p->words.size(); i++) 
		cout << p->words[i] << " ";
	cout << "\n";
}