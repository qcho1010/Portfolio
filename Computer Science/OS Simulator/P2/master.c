#include "master.h"

char msgerr[50] = "";					// string to hold the error messge and logging purpose
int maxChild = 19;								// max number of child
int maxTime = 10;								// max time to run
int childPid[19] = { 0 };              // saving child pid to properlly terminate the child
int ShmID;									// shared memory id
ShmPTR_t *ShmPTR;     				// shared memory pointer
int main (int argc, char *argv[]) {
	system("clear");
	signal(SIGINT, signalHandler);		// interrupt handler
	int cpid, i, status;
	
	// Argument handler
	int opt;	
	int flag;
	if (argc > 1) {
		if(strchr(argv[1],'-') != NULL) {
				while((opt = getopt(argc, argv, "htsf")) != -1) { // the loop, specifies the expected option 'i'
					switch(opt){
						case 'h':
							printInfo();
							break;
						case 't':
							flag = 1;
							break;
						case 's':
							flag = 2;
							break;
						default:
							exit(1);
							break;
							return 0;
					}
				}
		}
		
		int n;
		if (flag == 1) {
			n = atoi(argv[2]);
			if (n < 1 || n > 1000) {
				printf("Invalid range\n");
				exit(1);
			} else {
				maxTime = n;
				printf("Max time : %d seconds (default 10 seconds)\n", n);
			}
		} else if (flag == 2) {
			n = atoi(argv[2]);
			if (n < 2 || n > 19) {
				printf("Invalid range\n");
				exit(1);
			} else {
				maxChild = n;
				printf("# of salves : %d (default 19)\n", n);
			}
		}
		}
	// Initializing shared memory
	shmInit();
	
	// randomly fork child
	for (i=0; i < maxChild; i++)  {
		forkChild(i);
	}
	
	sprintf(msgerr, "Parent successfully done forking");
	writeLog(msgerr);
	
	sleep(maxTime);
	printf("Time's up,  now cleaning\n");
	cleanUp(SIGTERM);
	
	// Parent waits for all the children to terminate
   for (i=0; i < maxChild; i++) {
      cpid = wait(&status);
   }
}


// Display information
void printInfo () {
	printf("Command line arguments are as follows:\n");
	printf("-h\tDisplays this message and terminates.:\n");
	printf("-t n\tSets a max time of n seconds (default of 10, domain of [1,1000]) before terminating all children\n");
	printf("-s n\tProgram creates n slaves (default of 19, domain of [2,19]\n");
}
// Setting up shared memory
void shmInit () {
	key_t ShmKEY = ftok(".", 40);
	ShmID = shmget(ShmKEY, IPCD_SZ, 0666|IPC_CREAT);
	if (ShmID == -1) {
		perror("Failed to create shared memory segment");
        exit(1);
	}
	
	if (!(ShmPTR = (ShmPTR_t *)(shmat(ShmID, 0, 0)))) {
		perror("Failed to attach shared memory segment");
        exit(1);
    }
	sprintf(msgerr, "Shared memory attached");
	writeLog(msgerr);
}

// Forking Child Function
void forkChild(int child) {
    char childArg[5] = "";                        // String to hold child argument
    if ((childPid[child] = fork()) < 0) {
        sprintf(msgerr, "fork() for child %02d failed", child);
        writeLog(msgerr);
		perror(msgerr);
        cleanUp(SIGTERM);
        exit(1);
    } else {
        if (childPid[child] == 0) {
            sprintf(childArg, "%02d", child);
            sprintf(msgerr, "exec child %02d after fork", child);
			writeLog(msgerr);
            execl("./slave", "slave", childArg, (char *)NULL);
			printf ("EXEC Failed\n");
        }
    }
    return;
}

// Kill processes and remove the shared memeory
void cleanUp(int signo) {
    int i;
	for (i=0; i < maxChild; i++) 
		kill(childPid[i], signo);
	
    if ((shmctl(ShmID, IPC_RMID, 0) == -1) && (errno != EINTR)) {
        sprintf(msgerr, "Shared memory removed");
		writeLog(msgerr);
        perror(msgerr);
    }
    return;
}

// Log writing function
void writeLog(char *msg) {
    FILE *fp;
    if (!(fp = fopen("master.log", "a"))) {
        perror("Master: failed to open master.log");
        exit(1);
    }
    time_t now;
    struct tm *timeinfo;
    time(&now);
    timeinfo = localtime(&now);
	
    fprintf(fp, "%02d:%02d:%02d\t", timeinfo->tm_hour, timeinfo->tm_min, timeinfo->tm_sec);
    fprintf(fp, "Master:\t%s\n", msg);
    fclose(fp);
}

// Inturrupt handler
void signalHandler(int signo) {
	if (signo == SIGINT)
		fprintf(stderr,"\nDying because of the inturrupt\n");

	int i;
	for (i=0; i < 20; i++) 
		kill(childPid[i], signo);
	shmctl(ShmID, IPC_RMID,  0);
	exit(1);
}