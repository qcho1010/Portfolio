#ifndef COMMON_H
#define COMMON_H

#include <stdio.h>							// printf()
#include <stdlib.h>							// exit()
#include <time.h>							// time()
#include <wait.h>							// time()
#include <unistd.h>							// sleep(), etc.
#include <errno.h>							// perror()
#include <sys/ipc.h>						// Inter-process communication
#include <sys/shm.h>						// Shared memory
#include <sys/sem.h>						// Semaphores
#include <ctype.h> 							// isalpha()
#include <string.h>

#define maxWrite 3
#define IPCD_SZ sizeof(ShmPTR_t) 

// Emulate booleanism
typedef enum { FALSE, TRUE } bool_t;

typedef struct {
	int turn;
	int nProc;
	int flag[19];
	int size;
	
	// Shared variables for monitor implementation
	int writing;
	int num_waiting_procs;		 		// Processes waiting on this condition
	int next_count;	 						// Processes waiting to enter monitor
	int mutex, next, cs;	 				// Semids for the three semaphore
	struct sembuf wait, sig;
} ShmPTR_t;

void monitor (ShmPTR_t *d, int);
void conWait(ShmPTR_t *, int);
void conSignal(ShmPTR_t *, int); 
void semWait(ShmPTR_t *, int);
void semSignal(ShmPTR_t *, int); 
int initMonitor(ShmPTR_t *);
int initSem(key_t key, int); 
void criticalSection (int );

#endif
