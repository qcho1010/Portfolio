#include "common.h"

 
// Monitor Function
void monitor (ShmPTR_t  *d, int i) {
	semWait(d, d->mutex);

	// if (d->writing == 1) {
		// conWait(d, d->cs);
	// }
	
	// d->writing = 1;
	criticalSection(i); 	// Cretical Section
	// d->writing = 0;
	
	
	// conSignal(d, d->cs);
	
	if ( d->next_count > 0 )						// Someone waiting inside monitor?
		semSignal(d, d->next);					// Yes, wake him up
	else
		semSignal(d, d->mutex);				// No, free mutex so others can enter
 }

	
////////////////////////////////////////////////////////////////////////////////////////
// Conditional variables
////////////////////////////////////////////////////////////////////////////////////////

void conWait(ShmPTR_t *d, int semID) {
	d->num_waiting_procs++;					// # of processes waiting on this condition
	if ( d->next_count > 0 )						// Someone waiting inside monitor?
		semSignal(d, d->next);					// Yes, wake him up
	else
		semSignal(d, d->mutex);				// No, free mutex so others can enter
	
	semWait(d, semID);							// Start waiting for condition
	d->num_waiting_procs--;					// Wait over, decrement variable
	exit(0);
}

void conSignal(ShmPTR_t *d, int semID) {
	if ( d->num_waiting_procs <= 0 )		// Nobody waiting?
		exit(0);
	d->next_count++;								// # ready processes inside monitor
	semSignal(d, semID);						// Send signal
	semWait(d, d->next);							// I wait, let signalled process run
	d->next_count--;								// One less process in monitor
	exit(0);
}

void semWait(ShmPTR_t *d, int semID) {	
	if (semop(semID, &d->wait, 1) == -1)  {
		perror("Monitor: semWait->semop");
		exit(1);
	}
}

void semSignal(ShmPTR_t *d, int semID) {
	if (semop(semID, &d->sig, 1) == -1)  {
		perror("Monitor: semSig->semop");
		exit(1);
	}
}

////////////////////////////////////////////////////////////////////////////////////////
// Monitor & Semaphore Initialization 
////////////////////////////////////////////////////////////////////////////////////////
 
int initMonitor(ShmPTR_t *d) {
	key_t MutexKey = ftok(".", 42);
	key_t NextKey = ftok(".", 43);
	key_t csKey = ftok(".", 44);			// cretical section key
	
	d->mutex = initSem(MutexKey, 1);
	d->next = initSem(NextKey, 0);
	d->cs = initSem(csKey, 0);

	struct sembuf wait, sig;
	wait.sem_num = 0;
	wait.sem_op = -1;
	wait.sem_flg = SEM_UNDO;
	
	sig.sem_num = 0;
	sig.sem_op = 1;
	sig.sem_flg = SEM_UNDO;
	
	d->wait = wait;
	d->sig = sig;
	
	d->next_count = 0 ; 
	d->num_waiting_procs = 0;	
}

int initSem(key_t key, int semval) {
	int semID;
	if ((semID = semget(key, 1, 0666|IPC_CREAT)) == -1) {
		perror("Failed to create semaphore memory segment\n");
		exit(0);
	}
	if (semctl(semID, 0, SETVAL, semval) == -1) {
		perror("Failed to access semapahore\n");
		exit(0);
	}
	return semID;
}

 ////////////////////////////////////////////////////////////////////////////////////////
// Creditical Section
////////////////////////////////////////////////////////////////////////////////////////
void criticalSection (int curId) {
	char msg[50] = "";
	  
	FILE *fp;
	if (!(fp = fopen("cstest", "a"))) {
		perror("Slave: failed to open cstest");
		exit(1);
	}

	time_t now;
	struct tm *timeinfo;
	time(&now);
	timeinfo = localtime(&now);

	fprintf(fp, "File modified by process number %d at time", curId, msg);
	fprintf(fp, "\t%02d:%02d:%02d\n", timeinfo->tm_hour, timeinfo->tm_min, timeinfo->tm_sec);
	fclose(fp);
}


