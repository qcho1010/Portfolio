#ifndef COMMON_H
#define COMMON_H

#include <stdio.h>									// printf()
#include <stdlib.h>								// exit()
#include <time.h>									// time()
#include <wait.h>									// time()
#include <unistd.h>								// sleep(), etc.
#include <errno.h>								// perror()
#include <sys/ipc.h>								// Inter-process communication
#include <sys/shm.h>							// Shared memory
#include <ctype.h> 								// isalpha()
#include <string.h>

#define maxWrite 3
#define IPCD_SZ sizeof(ShmPTR_t) 

enum state {idle, want_in, in_cs};			// Enumerate consumer state flags

typedef struct {
	int turn;
	int nProc;
	int flag[19];
} ShmPTR_t;

// extern int maxChild;
// extern int maxTime;

void process (ShmPTR_t *, int);
void criticalSection (int );

#endif
