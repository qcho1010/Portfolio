#include "slave.h"

ShmPTR_t *ShmPTR;    

int main (int argc, char *argv[]) {
	int curId, i;			// Process ID or tag number
	curId= atoi(argv[1]);
	
	// Initializing shared memory
	shmInit();
	
	// Writing file
	for (i = 0; i < maxWrite; i++) {
		sleep(1);
		printf("process %d went to que\n", curId+1);
		monitor(ShmPTR, curId);
		printf("process %d finished the job\n", curId+1);
	}
	exit(2);
}

// Setting up shared memory
void shmInit () {
	key_t ShmKEY = ftok(".", 40);
	int ShmID = shmget(ShmKEY, IPCD_SZ, 0666);
	if (ShmID == -1) {
		perror("Failed to create shared memory segment");
		exit(2);
	}
	if (!(ShmPTR = (ShmPTR_t *)(shmat(ShmID, 0, 0)))) {
		perror("Failed to attach shared memory segment");
		exit(2);
    }
	// Increment the number of process created
	ShmPTR->nProc++;
}
