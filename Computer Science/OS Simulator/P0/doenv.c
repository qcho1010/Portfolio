// Kyu Cho
// CS 4760
// Assignment 1
// env utility
// 9/8/15

#include <stdio.h>	// perror()
#include <unistd.h> // getopt(), optind
#include <string.h> // strchr(), strncpy()
#include <stdlib.h> // system(), getenv(), setenv()

void get_env();
void update_env(char **, int i_flag);
extern char **environ; // Declaring external envrionment variable

/* command [-i] [name=value ...] [utility [argument ...]] */
int main(int argc, char **argv) {	
	int i_flag = 0;
	int err_flag = 0;
	int opt;	
	
	if (argc == 1) { // if there is no argument, output the current envrionment then terminate
		get_env();
		return 0;
	}
	
	if(strchr(argv[1],'-') != NULL) {
			while((opt = getopt(argc, argv, "i")) != -1) { // the loop, specifies the expected option 'i'
				switch(opt){
					case 'i':
						i_flag = 1;
						break;
					default:
						err_flag = 1;
						break;
				}
			}
	}
	
	char utility[100];
	int j = 0;
	for (j; j < 100; j++) // the loop initializing utility
		utility[j] = '\0';
		
	int i = 0;
	int count = 0;
	int utility_flag = 0;
	char **environ = NULL;
	environ = (char **)malloc(sizeof(char *)*argc);  // allocate memory to store the new variables

	for (i=optind; i < argc; i++) {  // the loop counts the number of variable by funding the '='
		if (strchr(argv[i], '=')) { // if strchr() found the '=' character in the argument, added into memory
			environ[count] = argv[i];  // copying the pointers from argv into the array
			count++;			
		}	else  { // if the arugment is not "=", store that argument as utility.
			strcat(utility, argv[i]); // if there is utility command, store it.			
			strcat(utility, " ");
			utility_flag = 1;
		}
	}

	environ[count] = NULL; // allocate extra NULL entry
	if(utility_flag == 1) { // if utility argument is included, update the env. value and apply them
		update_env(environ, i_flag);
		system(utility);
	} else if(utility_flag == 0 && err_flag == 0) { // if 'i' argument is included, but not utility argument
		if (*environ == NULL) // if 'i' argument is included but notrhing changed, terminate the program
			return 0;
		update_env(environ, i_flag); //
		get_env();
	} else  // Invalid utility or argument error handler
		perror("");
		
	return 0;
}

// The function modifies env. values
void update_env(char ** new_environ, int i_flag) {
	char *name;
    char *value;
    char *equalSign;
	name = (char *)malloc(sizeof(char)*30);
    value = (char *)malloc(sizeof(char)*1024);
	
	while(*new_environ) {
		equalSign = strchr(*new_environ, '=');	// pass the ptr to equalSign
        strncpy(name, *new_environ, equalSign - *new_environ); // copy from the beginning of the string till the equalSign, assign to 'name'
        strcpy(value, equalSign + 1); // copy from after the equalSign to the end, assign to 'value'		
		if(getenv(name) && i_flag == 0)
            setenv(name, value, 1); // 1 = replace(overwrite) with original value		
		else if (!getenv(name) && i_flag == 0)
            setenv(name, value, 0); // 0 = add into original list
		else if (i_flag == 1) {
			clearenv();
			if(!getenv(name)) 
				setenv(name, value, 0);	
		}
        new_environ++;	// point to next pointer
	}
}

// The function print out evn. values
void get_env() {
	int i = 0;
	
	for (i = 0; environ[i]; i++)
		printf("%s\n", environ[i]);
}