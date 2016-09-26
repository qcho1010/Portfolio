#include <stdio.h>
#include <string.h> // strchr(), strncpy
#include "log.h"

void information (void);

int main (int argc, char *argv[]) {
	char *str;
	char *loadedLog;
	data_t logData;
	int opt;	
	
	// the loop, specifies the expected option 'i'
	while((opt = getopt(argc, argv, "i")) != -1) { 
		switch(opt){
			case 'i':
				information();
				break;
		}
	}
	
	char *execName = argv[0];
	logData.execName = execName;
	
	// user defined err msg and add into the structure
	str = "Detailed error message 1";
	logData.logMsg = str;
	addmsg(logData);
	
	sleep(1);
	str = "Detailed error message 2";
	logData.logMsg = str;
	addmsg(logData);
	
	sleep(1);
	str = "Detailed error message 3";
	logData.logMsg = str;
	addmsg(logData);
	
	sleep(1);
	str = "Detailed error message 4";
	logData.logMsg = str;
	addmsg(logData);
	
	// load and print the data
	loadedLog = getlog();
	printf("%s", loadedLog);
	
	// save the log file
	savelog(execName);

	return 0;
}

// -i option function
void information (void) {
	char * str;
	str = "addmsg(data_t structure) // Passing the log msg structure\ngetlog(void) \t\t// Retriveing entire log messages\nsavelog(str *filename) \t// Saving current log into the file and auto clean";
	printf("%s\n", str);
}