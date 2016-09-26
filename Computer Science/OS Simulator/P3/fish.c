#include <sys/types.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <time.h>
#include "swim_mill.h"

struct Data data[20];

void main() {	
	int j,  fishORpellet = 1;
	double delay = 0, timer = 0;
	key_t ShmKEY = ftok(".", 40), ShmKEY2 = ftok(".", 41);
	
	// Get shared memory segment identifier
    int ShmID = shmget(ShmKEY, sizeof(int[23][23]), 0666);
	int ShmID2 = shmget(ShmKEY2, sizeof(struct Memory), 0666);
	if (ShmID == -1 ||ShmID2 == -1) {
		perror("Failed to create shared memory segment");
		exit(2);
	}
	char (*ShmPTR)[23] = shmat(ShmID, NULL, 0);
	struct Memory *ShmPTR2 = shmat(ShmID2, NULL, 0);
	if ((int *)ShmPTR  ==  (int *)-1 || (int *)ShmPTR2 == (int *)-1) {
		perror("Failed to attach shared memory segment");
		shmctl(ShmID, IPC_RMID,  0);
		shmctl(ShmID2, IPC_RMID,  0);
		exit(2);
	}
	
	// Initializing
	ShmPTR2->fishX=11;
	ShmPTR2->n++;
	ShmPTR2->nTotal++;
	ShmPTR2->flag[0] = 1;
	ShmPTR2->empty[0] = 0;
	
	ShmPTR[22][ShmPTR2->fishX] = 'P';
	display(ShmPTR);		
	for (j=0; j<20; j++) {			
		data[j].empty = 0;
		data[j].totalDist = 0;
		data[j].pelletX = 0;
	}

	j = 0;
	while (ShmPTR2->status == -1);
	int time = 0;
	while (time < 400 || ShmPTR2->nTotal > 1) {
		process(ShmPTR, ShmPTR2,  0, fishORpellet);
		usleep(1000000/20);
		time++;
	}
	
	shmdt((void *) ShmPTR);
	shmdt((void *) ShmPTR2);
	exit (2) ;
}
