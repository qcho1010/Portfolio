#include <stdio.h>								// printf()
#include <stdlib.h>								// exit()
#include <time.h>								// time()
#include <wait.h>								// time()
#include <unistd.h>								// sleep(), etc.
#include <errno.h>								// perror()
#include <sys/ipc.h>							// Inter-process communication
#include <sys/shm.h>							// Shared memory
#include <sys/sem.h>							// Semaphores
#define QUANTUM 200								// Time quantum

#define MAX 18
#define IPCD_SZ (sizeof(ShmPTR_t))				// Set the size of the IPC data structure
#define PCB_SZ (sizeof(pcb_t))					// Set the size of the PCB data structure
#define ShmPTR_SZ (IPCD_SZ + (18 * PCB_SZ))		// Set the total size of the shared data structure

// Data structure for process control block
typedef struct {
	float prevTime;						// Time of last execution (taken from logical clock)
	int prevUsed;							// Time used in previous burst
	int cpu_tt;								// Total CPU time in milliseconds
	int sys_tt;								// Total system time in milliseconds
	int done;							// Indicate if the child has run to completion
	int run;								// Indicate if the child has run since being dispatched
} pcb_t;

// Data structure for shared memory
typedef struct {
	float run_tt;							// Total run in system 
	float wait_tt;						// Total wait time 
	float cpu_tt;							// Total cpu using time
	int fork_tt;							// Total number of fork
	int done_tt;							// Total number of work done
	unsigned int secTime;						// Clock seconds
	unsigned int nanoTime;					// Nanoseconds since the last clock second
	int dispatchPID;							// The currently scheduled process ID
	int quantum;								// The time quantum tha the scheduled PID will run for
	int wait;								// wait signal
	pcb_t childPCB[MAX];					// PCB array
} ShmPTR_t;

void sig_handler(int );
void writelog(char *);
void cleanup(int );
void initPCB(int );
void waitSem(int ); 
int countChild();
void forkChild(int);
void report();

void sig_handler(int);
void writelog(char *);
void signalSem(int );