#ifndef LOG_H
#define LOG_H

#include <time.h>

// nested structure to store the detail info.
typedef struct data_struct {
	time_t time;
	char *timeStr;
	char *execName;
	char *logMsg;
} data_t;

// function prototype
int addmsg(data_t);
char *getTimeStamp(void);
void clearlog(void);
char *getlog(void);
int savelog(char *);

#endif