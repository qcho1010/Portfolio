#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include "log.h"
 
 //getopt, time stamp must be done in log.c, name of the main should be printeds
typedef struct list_struct {
     data_t item;
     struct list_struct *next;
} log_t;
 
static log_t *headptr = NULL;
static log_t *tailptr = NULL;
int error;
 
int addmsg(data_t data) {	
	log_t *msgStruct;
	int msgSize;
	
	// allocates enough space for a string containing the entire log, 
	// total size = size of log structure, length of the incomming string and +1 for \n
	msgSize = sizeof(log_t) +  sizeof(data) + strlen(data.logMsg) + 1;
	
	// if it can't add message size, exit
	if ((msgStruct = (log_t*)(malloc(msgSize)))	== NULL) {
		errno = error;
		perror("Memory allocation failed\n");		
		return -1;
	}

	// copy values
	msgStruct->item.timeStr = getTimeStamp();
	msgStruct->item.execName = data.execName;
	msgStruct->item.logMsg = (char *)msgStruct + sizeof(log_t);
	strcpy(msgStruct->item.logMsg, data.logMsg);

	// if this is the first time executing
	// then assign head pointer to msgStruct, since it's empty already
	if(headptr == NULL) headptr = msgStruct;	
	// if there are already que
	// then assign current struct into next and wait for the turn.
	else tailptr->next = msgStruct;
	tailptr = msgStruct;
	
	// If successful return 0 else -1
   return 0;
}

// record time stamp
char *getTimeStamp(void) {
	time_t now;
	now = time(NULL);

	char *timeStr = malloc(sizeof(now)+1);
	struct tm *timeInfo;

	// convert the time info into proper formmat
	timeInfo = localtime(&now);

	// write the log
	sprintf(timeStr, "%02d:%02d:%02d\t", timeInfo->tm_hour, timeInfo->tm_min, timeInfo->tm_sec);

	return timeStr;
}

// releases all the storage that has been allocated for 
// the logged messages and empties the list of logged messages.
void clearlog(void) {
	// copy current ptr in temperary structure
    log_t *tmpStruct = headptr;
	
		// loop continues untill all head structures are empty
    while (tmpStruct) {
        tmpStruct = headptr->next;
        free(headptr);
        headptr = tmpStruct;
    }
}

 // copies the log into this string, and returns a pointer to the string
 char *getlog(void) { 
 	// copy current ptr in nxtStruct
	log_t *nxtStruct = headptr;
	
	int strSize;
	char *wholeLog;
	// loop continues untill all remaining structures are empty
	while (nxtStruct) {
		// get the string size to allocate the memory, +1 for \n
		strSize += (strlen(nxtStruct->item.timeStr) + strlen(nxtStruct->item.execName) + strlen(nxtStruct->item.logMsg) + 1);
		nxtStruct = nxtStruct->next;
	}

	// assigning size of wholeLog
	if ((wholeLog = (char *)malloc(strSize + 1)) == NULL) {
		errno = error;
		perror("Memory allocation failed\n");		
		return NULL;
	}
	
	// go back to head pointer
	nxtStruct = headptr;
	// loop continues untill all remaining structures are empty
	while (nxtStruct) {
		if (nxtStruct == headptr) 
			strcpy(wholeLog, nxtStruct->item.timeStr);
		else
			strcat(wholeLog, nxtStruct->item.timeStr);
		strcat(strcat(wholeLog, nxtStruct->item.execName), "\t");
		strcat(strcat(wholeLog, nxtStruct->item.logMsg), "\n");
		
		nxtStruct = nxtStruct->next;
	}
	
  	return wholeLog;
 }
  
// saves the logged messages to a disk file.
int savelog(char *filename) {
	FILE *file;
	char fullFileName[15] = "";
	
	if (filename == NULL) {
		errno = error;
		perror("File name isn't valied\n");		
		return -1;
	}
	
	// add .log extension to the filename
	sprintf(fullFileName, "%s.log", filename);

	if ((file = fopen(fullFileName, "a")) == NULL) {
		errno = error;
		perror("File creation failed\n");		
		return -1;
	}
	
	if (!getlog()) {
		errno = error;
		perror("No log to save\n");		
		return -1;
	} else 
		fprintf(file, "%s", getlog());

	if (fclose(file)) {
		errno = error;
		perror("File saving failed\n");		
		return -1;
	}
	
	// Clear the log
	clearlog();
	
	// If successful return 0 else -1
	return 0;
}
