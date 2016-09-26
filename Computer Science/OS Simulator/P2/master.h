#ifndef MASTER_H
#define MASTER_H

#include "common.h"

void argHandler (int argc, const char *argv[]);
void printInfo();
void forkChild(int);
void writeLog(char *); 
void cleanUp(int);
void signalHandler(int);
void shmInit ();

#endif
