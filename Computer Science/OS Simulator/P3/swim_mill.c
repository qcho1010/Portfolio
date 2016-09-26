#include <sys/types.h>  
#include <sys/ipc.h> 
#include <sys/shm.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h> 
#include <stdint.h>
#include <signal.h>
#include <unistd.h>
#include <time.h>
#include "swim_mill.h"

int usr_interrupt;
int ShmID;
int ShmID2;
char (*ShmPTR)[11] ;
struct Memory *ShmPTR2;
int idArr[20];

void sig_handler(int signo) {
	int i;
	if (signo == SIGINT)
		fprintf(stderr,"\nParent: Dying because of the inturrupt\n");
	usr_interrupt=1;
	
	for (i=0; i<20; i++) 
		kill(idArr[i], signo);
	shmctl(ShmID, IPC_RMID,  0);
	shmctl(ShmID2, IPC_RMID,  0);
	exit(1);
}

int main() {
	signal(SIGINT, sig_handler);
	srand(time(0));
    system("clear");
	int x, y, i, status; 
	double delay = 0.0;
	pid_t cpid;
	key_t ShmKEY = ftok(".", 40), ShmKEY2 = ftok(".", 41);
	
	// Get shared memory segment identifier
    ShmID = shmget(ShmKEY, sizeof(int[23][23]), 0666|IPC_CREAT|IPC_EXCL);
	ShmID2 = shmget(ShmKEY2, sizeof(struct Memory), 0666|IPC_CREAT|IPC_EXCL);
	if (ShmID == -1 ||ShmID2 == -1) {
		perror("Failed to create shared memory segment");
		return 1;
	}
	char (*ShmPTR)[23] = shmat(ShmID, NULL, 0);
	struct Memory *ShmPTR2 = shmat(ShmID2, NULL, 0);
	if ((int *)ShmPTR  ==  (int *)-1 || (int *)ShmPTR2 == (int *)-1) {
      perror("Failed to attach shared memory segment");
	  shmctl(ShmID, IPC_RMID,  0);
	  shmctl(ShmID2, IPC_RMID,  0);
      return 1;
	}
	int n = 20;  // number of total fish and pellet processors
	ShmPTR2->status = -1;	// Set 'not ready' untill the first pellet is dropped
	
	for (y=0;y<20; y++) {			// Initialize to idle state to all pellets
		ShmPTR2->empty[y] = 1;		// Set as empty
	}

	// Initializing the grid
	for (y=0; y<23; y++) {
		for (x=0; x<23; x++) 
			ShmPTR[y][x] = '.';
	}
	
	// Fish process
	cpid = fork();
	idArr[0] = cpid;
	if (cpid == 0) {
		execlp("fish", "fish", NULL);
		printf ("EXEC Failed\n");
	} else if (cpid == -1) {
		perror ("Failed to create fish process") ;
		return 1;
	} else {
		// parents create multiple pellet process at randome intervel
		for (i=0; i < (n-1); i++) {
			delay = rand()%1 + 1;
			usleep(1000000*delay);
			cpid = fork();
			idArr[i+1] = cpid;
		  if (cpid == 0) {
			  execlp("pellet", "pellet", NULL);
			  printf ("EXEC Failed\n");
		  } else if (cpid == -1) {
			  perror ("Failed to create pellet process") ;
			  shmdt((void *)ShmPTR);
			  shmdt((void *)ShmPTR2);
			  shmctl(ShmID, IPC_RMID,  0);
			  shmctl(ShmID2, IPC_RMID,  0);
			return 1;
		  }
		}
	}
	// Parent waits for all the children to terminate
   for (i=0; i < n; i++) {
      cpid = wait(&status);
	  // if (WEXITSTATUS(status) != 0)
		  // printf("Parent(%d): Child %d exited with status %d\n", getpid(), cpid, WEXITSTATUS(status));
	  // else 
		  // printf("Parent(%d): Child %d was killed off with status %d\n", getpid(), cpid, WEXITSTATUS(status));
   }
   
	shmdt((void *)ShmPTR);
	shmdt((void *)ShmPTR2);
	shmctl(ShmID, IPC_RMID,  0);
	shmctl(ShmID2, IPC_RMID,  0);
	return 0;
}







