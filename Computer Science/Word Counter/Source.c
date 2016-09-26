#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>
#define wordoccupy 50
#define lastletter 1
#define other 0
void lowercasewords(char *);
void countword(FILE *);

struct Btree {
	char *word;
	int count;
	struct Btree *left;
	struct Btree *right;
};

//insert method, checks left and right child
struct Btree *addBtree(struct Btree *p, char *word) {
	int cmp;

	if (p == NULL) {
		p = (struct Btree *) malloc(sizeof(struct Btree));
		p->word = strdup(word);
		p->count = 1;
		p->left = p->right = NULL;
	}
	else if ((cmp = strcmp(word, p->word)) == 0)
		p->count++;
	else if (cmp < 0)
		p->left = addBtree(p->left, word);
	else
		p->right = addBtree(p->right, word);

	return p;
}

// print all nodes in order 
void treeprint(struct Btree *p) {
	if (p != NULL) {
		treeprint(p->left);
		printf("%s\t%6d\n", p->word, p->count);
		treeprint(p->right);
	}
}

int main() {
	char inputfile[20];
	printf("Enter inputfile name\n");
	scanf("%s", inputfile);
	FILE *fp = fopen(inputfile, "r");
	countword(fp);

	return 1;
}

//Gives a count of how many words there are in file then 
//sends it to insert method
void countword(FILE *fp) {
	struct Btree *root = NULL;
	char word[wordoccupy + 1];
	int end;
	while ((end = getword(fp, word, wordoccupy)) == 1) {
		root = addBtree(root, word);
	}
	// last word
	if (word[0] != '\0') {
		root = addBtree(root, word);
	}
	treeprint(root);
}

//Gets word from file then counts it
int getword(FILE *fp, char *word, int limit) {
	int i = 0, last = other;
	char c;
	while ((c = fgetc(fp)) != EOF) {
		if (isalpha(c)) {
			lowercasewords(word);
			last = lastletter;
			if (i < wordoccupy)
				word[i++] = c;
		}
		else {
			if (last) {
				word[i] = '\0';
				return 1;
			}
			last = other;
		}
	}
	// reach EOF
	word[i] = '\0';
	return 0;
}

//make lowercase
void lowercasewords(char *word){
	int i;
	for (i = 0; word[i]; i++)
		word[i] = tolower(word[i]);
}
