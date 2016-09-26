#include <sys/types.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <unistd.h>
#include <time.h>
#include "swim_mill.h"

struct Data2 data2;
double speed;

void main() {
	srand(time(0));
	double delay = 0.0;
	int j, pelletX, pelletY , i = 0x80;
	int myIndex, fishORpellet = 0, wait = 0;
	key_t ShmKEY = ftok(".", 40), ShmKEY2 = ftok(".", 41);
	
	// Get shared memory segment identifier
    int ShmID = shmget(ShmKEY, sizeof(int[11][11]), 0666);
	int ShmID2 = shmget(ShmKEY2, sizeof(struct Memory), 0666);
	if (ShmID == -1 ||ShmID2 == -1) {
		perror("Failed to create shared memory segment");
		exit(3);
	}
	char (*ShmPTR)[23] = shmat(ShmID, NULL, 0);
	struct Memory *ShmPTR2 = shmat(ShmID2, NULL, 0);
	if ((int *)ShmPTR  ==  (int *)-1 || (int *)ShmPTR2 == (int *)-1) {
		perror("Failed to attach shared memory segment");
		shmctl(ShmID, IPC_RMID,  0);
		shmctl(ShmID2, IPC_RMID,  0);
		exit(3);
	}
	
	// Initializing
	delay = rand() % 1 + 2;
	usleep(1000000*delay);
	pelletX = rand() % 22;
	pelletY = rand() % 21;
	data2.pelletX = pelletX;
	data2.pelletY = pelletY;
	ShmPTR2->n++;
	ShmPTR2->nTotal++;
	data2.eatten = 0;
	ShmPTR[pelletY][pelletX] = i;
	ShmPTR2->status = 1;		// Notify fish that the new pellet is dropped
	
	int n = ShmPTR2->n;	
	int k;
	for (k=0; k<n; k++) {			// Initialize to idle state to all pellets
		if (ShmPTR2->empty[k]) {		// if flag is empty 
			ShmPTR2->flag[k] = 1;		// Set as idle
			ShmPTR2->empty[k] = 0;		// Set the flag isn't empty
			myIndex = k;		// extract the Index
			break;	
		}
	}
	int time = 0;
	while ( data2.eatten != 1) { // If the pellet isn't eatten it doesn't die
		usleep(1000000/(10 - rand()%8));		// Random pellet speed
		speed = 10 - rand()%8;
		process(ShmPTR, ShmPTR2, myIndex, fishORpellet);
	}
	ShmPTR2->nTotal--;
	ShmPTR2->empty[i] = 1;
	
	shmdt((void *) ShmPTR);
	shmdt((void *) ShmPTR2);
	exit (3) ;
}
 
