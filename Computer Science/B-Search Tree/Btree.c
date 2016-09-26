/*
Kyu Cho
CS3130
4/17/2015
Project 3
Description : This is a user-driven program to insert, delate, search and sort the values.
*/
#include <stddef.h>
#include <malloc.h>
#include <stdio.h>
#include "BinaryTree.h"

int main() {
	TREE root = NULL;
	TREE search = NULL;
	TREE newnode = NULL;

	int i = 0;
	int key = 0;
	int input = 0;
	int arr[] = {30, 10, 45, 38, 20, 50, 25, 33, 8, 12 };

	printf("Origianl     : ");
	for (i = 0; i < 10; i++) {
		newnode = (TREE)malloc(sizeof(struct tnode));
		newnode->left =	newnode->right = newnode->parent = NULL;
		newnode->key = arr[i];

		printf("%d ", newnode->key);		
		tree_insert(&root, newnode);
	}
	printf("\n--------------------------------------------\n");
	display(root);
	do {		
		input =	menu();
		if (input == 1) {	// Insertion
			printf("Enter key ");
			scanf("%d", &key);
			printf("--------------------------------------------\n");
			newnode = (TREE)malloc(sizeof(struct tnode));
			newnode->left = newnode->right = newnode->parent = NULL;
			newnode->key = key;
			printf("%d is inserted", newnode->key);
			tree_insert(&root, newnode);
			printf("\nIn order     : ");
			inorder_tree_walk(root);
			printf("\n");
		} else if (input == 2) {	// Search
			printf("Enter key ");
			scanf("%d", &key);
			printf("--------------------------------------------\n");
			printf("Sequences : ");
			search = tree_search(&root, key);
			printf("\n");
		} else if (input == 3) {	// Deletion
			printf("Enter key ");
			scanf("%d", &key);
			printf("--------------------------------------------\n");
			printf("Sequences : ");
			search = tree_search(&root, key);
			if (search) {
				printf("\n%d is deleted", key);
				tree_delete(&root, search);
				printf("\nIn order     : ");
				inorder_tree_walk(root);
				printf("\n");
			} else printf("\n");
		} else if (input == 4) {	// Display
			display(root);
		} else if (input == 5) {	// Quit
			break;
		} else {
			printf("Wrong input\n");
		}
	} while (input != 5);

	return 0;
}

void tree_insert(TREE *root, TREE z) {
	TREE y = NULL;
	TREE x = *root;

	while (x != NULL) {
		y = x;
		if (z->key < x->key)
			x = x->left;
		else
			x = x->right;
	}
	z->parent = y;
	if (y == NULL)
		*root = z;
	else if (z->key < y->key)
		y->left = z;
	else
		y->right = z;
}

TREE tree_search(TREE *root, int key) {
	TREE x = *root;
	while (x != NULL && key != x->key) {
		if (key < x->key && x->left != NULL) {
			x = x->left;
			printf("%d ", x->key);
		}
		else if (key > x->key && x->right != NULL) {
			x = x->right;
			printf("%d ", x->key);
		}
		else {
			printf("... NULL Not found");
			x = NULL;
		}
	}
	return x;
}

TREE tree_delete(TREE *root, TREE z) {
	TREE y = NULL;
	TREE x = NULL;

	if (z->left == NULL || z->right == NULL) 
		y = z;
	else 
		y = tree_successor(z);

	if (y->left != NULL)
		x = y->left;
	else
		x = y->right;

	if (x != NULL)
		x->parent = y->parent;

	if (y->parent == NULL)
		*root = x;
	else if (y == (y->parent->left))
		(y->parent->left) = x;
	else
		(y->parent->right) = x;

	if (y != z)
		z->key = y->key;
	return y;
}

TREE tree_successor(TREE x) {
	if (x->right != NULL)
		return tree_minimum(x->right);

	while (x->parent != NULL && x == x->parent->right)	{
		x = x->parent;
		x->parent = x->parent->parent;
	}	
	return x->parent;
}

TREE tree_minimum(TREE x) {
	while (x->left)
		x = x->left;
	return x;
}

TREE tree_maximum(TREE x) {
	while (x->right)
		x = x->right;
	return x;
}

void inorder_tree_walk(TREE root) {
	TREE p = root;
	if (p != NULL)	{
		inorder_tree_walk(p->left);
		printf("%d ", p->key);
		inorder_tree_walk(p->right);
	}
}

void postorder_tree_walk(TREE root) {
	TREE p = root;
	if (p != NULL) {		
		postorder_tree_walk(p->left);
		postorder_tree_walk(p->right);
		printf("%d ", p->key);
	}
}

void preorder_tree_walk(TREE root) {
	TREE p = root;
	if (p != NULL) {
		printf("%d ", p->key);
		preorder_tree_walk(p->left);		
		preorder_tree_walk(p->right);
	}
}

int menu() {
	int input;
	printf("--------------------------------------------\n");
	printf("Select one of the following options\n");
	printf("1. Insert new node\n");
	printf("2. Search node\n");
	printf("3. Delate node\n");
	printf("4. Display\n");
	printf("5. Quit\n");
	scanf("%d", &input);
	printf("--------------------------------------------\n");
	return input;
}

void display(TREE root) {
	printf("In Order     : ");
	inorder_tree_walk(root);
	printf("\nPost Order   : ");
	postorder_tree_walk(root);
	printf("\nPre Order    : ");
	preorder_tree_walk(root);
	printf("\n");
}