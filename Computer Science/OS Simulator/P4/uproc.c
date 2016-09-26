#include "oss.h"						// IPC Data structure

int signum;										// Hold a signal number
int curI;											// My child ID
int SemID;										// Semaphore ID
int curPID;										// My process ID
int ShmID;										// Shared memory ID
char msgerr[50];								// Hold a message to be passed to perror() or writelog()
ShmPTR_t *ShmPTR;						// Pointer for shared memory

int main(int argc, char *argv[]) {
	signal(SIGINT, sig_handler);

	srand(time(NULL));						// Seed the random number generator
	int ShmKEY = ftok(".", 40);			// Shared memory key
	int SemKEY = ftok(".", 41);			// Semaphore key
	int sleepSecs;								// Random sleep variable
	int allQuant;									// Use the whole quantum or not
	unsigned int quantUsed;				// How much of the quantum was used
	curI = atoi(argv[1]);						// Current PID Index
	curPID = getpid();							// Get my process ID

	sprintf(msgerr, "Starting new run with PID %d\n", curPID);
	writelog(msgerr);

	// Semaphore Memory Initialization
	if ((ShmID = shmget(ShmKEY, ShmPTR_SZ, 0600)) == -1) {
		sprintf(msgerr, "userproc %02d: shmget", curI);
		perror(msgerr);
		exit(1);
	}
	if (!(ShmPTR = (ShmPTR_t *)(shmat(ShmID, 0, 0)))) {
		sprintf(msgerr, "userproc %02d: shmat", curI);
		perror(msgerr);
		exit(1);
	}
	writelog("Successfully attached to shared memory for IPC data");

	
	// Semaphore Memory Initialization
	if ((SemID = semget(SemKEY, 1, 0600)) == -1) {
		sprintf(msgerr, "userproc %02d: semget", curI);
		perror(msgerr);
		exit(1);
	}
	writelog("Successfully attached to scheduling semaphore");

	// Wait till all processes are created
	while(ShmPTR->wait == 1);
	ShmPTR->fork_tt++;
	
	while (1) {
		// If this process is schadule to run,
		if ( ShmPTR->dispatchPID == curPID && ShmPTR->childPCB[curI].run == 0 ) {
			sprintf(msgerr, "Detected dispatch for my PID (%d)\n", curPID);
			writelog(msgerr);

			ShmPTR->childPCB[curI].prevTime = (float)ShmPTR->secTime + ((float)ShmPTR->nanoTime / 1000);
			sprintf(msgerr, "Set my last run time to: %f", ShmPTR->childPCB[curI].prevTime);
			writelog(msgerr);

			// Randomly selecting the amount of Quentum to use
			allQuant = rand() % 10;	
			if (allQuant < 2) {		
				quantUsed = ShmPTR->quantum;
				sprintf(msgerr, "Using full quantum");
				writelog(msgerr);
			} else {
				quantUsed = 50 + rand() % ShmPTR->quantum;
				sprintf(msgerr, "Using %d of quantum", quantUsed);
				writelog(msgerr);
			}
			
			// Updating values
			ShmPTR->childPCB[curI].prevUsed = quantUsed;
			ShmPTR->childPCB[curI].cpu_tt += quantUsed;
			sprintf(msgerr, "Total CPU this run: %d", ShmPTR->childPCB[curI].cpu_tt);
			writelog(msgerr);
			ShmPTR->childPCB[curI].run = 1;
			
			// Sending Signal for  Next Schadule
			signalSem(SemID);
	
			if ( ShmPTR->childPCB[curI].cpu_tt >= 500 ) {
				ShmPTR->done_tt++;
				ShmPTR->childPCB[curI].done = 1;
				sprintf(msgerr, "Used max quantum - this run complete. Exiting.\n\n");
				writelog(msgerr);
				exit(0);
			}
		}
		sleepSecs = 1;
		sprintf(msgerr, "Sleep %d", sleepSecs);
		writelog(msgerr);
		sleep(sleepSecs);
	}
	return 0;
}

// Singal Handling Function
void sig_handler(int signo) {
	fprintf(stderr,"\nChild: Dying because of the inturrupt\n");
	exit(1);
}

// Log Function
void writelog(char *msg) {
	char logname[10] = "";
	sprintf(logname, "userproc%02d.log", curI);

	FILE *fp;
	if (!(fp = fopen(logname, "a"))) {
		sprintf(msgerr, "userproc %02d: opening %s", curI, logname);
		perror(msgerr);
		exit(1);
	}
	time_t now;
	struct tm *timeinfo;
	time(&now);
	timeinfo = localtime(&now);
	
	fprintf(fp, "%02d:%02d:%02d\t", timeinfo->tm_hour, timeinfo->tm_min, timeinfo->tm_sec);
	fprintf(fp, "user %02d:\t%s\n", curI, msg);
	fclose(fp);
}

// Singal Function
void signalSem(int semid) {
	sprintf(msgerr, "signalSem called for semid %d", semid);
	writelog(msgerr);

	struct sembuf sbuf;							// Semaphore operation struct
	sbuf.sem_num = 0;							
	sbuf.sem_op = 1;						
	sbuf.sem_flg = 0;						
	if (semop(semid, &sbuf, 1) == -1)  {
			signal(SIGINT, sig_handler);
			exit(1);
	}
	return;
}

