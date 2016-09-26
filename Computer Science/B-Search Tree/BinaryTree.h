
#ifndef BINARYTREE_H_
#define BINARYTREE_H_

typedef struct tnode
{
	int key;
	struct tnode *parent;
	struct tnode *left;
	struct tnode *right;
}*TREE;

//print the tree
void inorder_tree_walk(TREE);

void preorder_tree_walk(TREE);

void postorder_tree_walk(TREE);

void display(TREE);

int menu();

//search the node
TREE tree_search(TREE *, int);

//the successor of the node x
TREE tree_successor(TREE);

// insert node
void tree_insert(TREE *, TREE);

// delete node from tree
TREE tree_delete(TREE *, TREE);

//return the minimum node
TREE tree_minimum(TREE);

// return the maximum node
TREE tree_maximum(TREE);

#endif /* BINARYTREE_H_ */
