#include "oss.h"                           

int ShmID;                                  
int signum;                                     
char msgerr[50] = "";                         
ShmPTR_t *ShmPTR;                                    
int SemID_clock;                            
int SemID_res;                                  
int mypid;                                      
int curI;                                  

int main(int argc, char *argv[]) {
    srand(time(NULL));                        
    int ShmKEY  = ftok(".", 43);     
    int SemKEY1 = ftok(".", 44);        
    int SemKEY2  = ftok(".", 45);       
    int sleep_secs, n, wait_milli, release, request;                      
    unsigned int start_sec;                 
	curI = atoi(argv[1]);
    mypid = getpid();                            

    sprintf(msgerr, "New child forked PID: %d", mypid);
    writelog(msgerr);

	// Shared Memory Initialization
    if ((ShmID = shmget(ShmKEY, IPCD_SZ, 0600)) == -1) {
		perror("shmget Err");
        exit(1);
    }
    if ( ! (ShmPTR = (ShmPTR_t *)(shmat(ShmID, 0, 0)))) {
		perror("shmat Err");
        exit(1);
    }
	// Semaphore Memory Initialization for Clock
    if ((SemID_clock = semget(SemKEY1, 1, 0600)) == -1) {
		perror("semget Err clock");
        exit(1);
    }
	// Semaphore Memory Initialization for Resource
    if ((SemID_res = semget(SemKEY2, 1, 0600)) == -1) {
		perror("semget Err resource");
        exit(1);
    }
    writelog("Successfully Attached clock and resource semaphores");
	
    int res_use;                                 
    for (n = 0; n < resMax; n++) {
        res_use = rand() % 4;	// have 25% of chance to use all resources
        if ( res_use == 1 ) {
            ShmPTR->resources[n].max_claim[curI] = 1 + (rand() % ShmPTR->resources[n].inst_tt);
            sprintf(msgerr, "Resource Claimed = MAX %d", ShmPTR->resources[n].max_claim[curI]);
            writelog(msgerr);
        }
    }

    // Initialize statistics
    ShmPTR->throughput[curI] = 0;
    ShmPTR->wait_time[curI] = 0;
    ShmPTR->cpu_util[curI] = 0;
    start_sec = ShmPTR->secTime;

    while (1) {
        if ( sigcheck() ) {
            sprintf(msgerr, "Received signal %d - exiting...", signum);
            writelog(msgerr);
            break;
        }

        if ( (rand() % 10) == 1 && ShmPTR->secTime - start_sec > 0 ) {
            for (n = 0; n < resMax; n++) {
                ShmPTR->resources[n].request[curI] = 0;
                ShmPTR->resources[n].release[curI] = ShmPTR->resources[n].allocated[curI];
            }
            ShmPTR->childTaken[curI] = 0;
            exit(0);
        }


        for (n = 0; n < resMax; n++) {
            // Request or Release algorithm 
            if ( ShmPTR->resources[n].allocated[curI] > 0 && rand() % 2 == 1 ) {
                if ( rand() % 2 == 1 ) {
                    release = rand() % ShmPTR->resources[n].allocated[curI];

                    sem_wait(SemID_res);        
                    ShmPTR->resources[n].release[curI] += release;
                    sem_signal(SemID_res);     

                    sprintf(msgerr, "Released %d instances of resource %d", release, n);
                    writelog(msgerr);

                    ShmPTR->cpu_util[curI] += 10; 
                }
            } else if ( ShmPTR->resources[n].request[curI] == 0 ) {
                if ( ShmPTR->resources[n].max_claim[curI] > 0 && rand() % 2 == 1 ) {
                    // Requesting Resource 
                    request = rand()%( ShmPTR->resources[n].max_claim[curI] - ShmPTR->resources[n].allocated[curI] );

                    if ( request > 0 ) {        // negative number avoidance
                        sem_wait(SemID_res);     
                        ShmPTR->resources[n].request[curI] = request;
                        sem_signal(SemID_res);  

                        sprintf(msgerr, "Requested %d instances of resource %d", request, n);
                        writelog(msgerr);

                        ShmPTR->cpu_util[curI] += 15000000; 
                    }
                }
            }
        }

		// Random time btw 0 to 250
        wait_milli = 1 + ( rand() % 250 );       

        sem_wait(SemID_clock);       
		
        ShmPTR->milliTime += wait_milli;
        if ( ShmPTR->milliTime >= 1000 ) {
            ShmPTR->secTime++;
            ShmPTR->milliTime -= 1000;
        }
        sem_signal(SemID_clock);              
		ShmPTR->wait_time[curI] += wait_milli;

		
        sprintf(msgerr, "Logical clock is now %d.%03d%s.%03d", ShmPTR->secTime, ShmPTR->milliTime, msgerr, ShmPTR->nanoTime);
        writelog(msgerr);

        sleep_secs = 1;
        sprintf(msgerr, "Sleep %d", sleep_secs);
        writelog(msgerr);
        sleep(sleep_secs);
    }

    return 0;
}

// Catch signals
void sigproc(int sig) {
    signum = sig;
}

// Process signals
int sigcheck() {
    signal(SIGINT, sigproc);
    signal(SIGTERM, sigproc);
	if (signum == 2) fprintf(stderr, "userproc %02d: Caught CTRL-C (SIGINT)\n", curI);
    return 0;
}

// Log function
void writelog(char *msg) {
    char logname[15] = "";
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
    fprintf(fp, "userproc %02d:\t%s\n", curI, msg);
    fclose(fp);
}

// Wait Function
void sem_wait(int semid) {
	struct sembuf sbuf;					
	sbuf.sem_num = 0;							
	sbuf.sem_op = -1;							
	sbuf.sem_flg = 0;							
	if (semop(semid, &sbuf, 1) == -1) {
			exit(0);
	}
	return;
}

// Singal Function
void sem_signal(int semid) {
	struct sembuf sbuf;							
	sbuf.sem_num = 0;							
	sbuf.sem_op = 1;						
	sbuf.sem_flg = 0;						
	if (semop(semid, &sbuf, 1) == -1) {
			exit(1);
	}
	return;
}
