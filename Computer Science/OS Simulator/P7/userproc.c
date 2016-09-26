// RCS DATA AT BOTTOM OF FILE


#include <stdio.h>                               // printf()
#include <stdlib.h>                              // exit()
#include <unistd.h>                              // sleep(), etc.
#include <time.h>                                // time()
#include <wait.h>                                // wait()
#include <errno.h>                               // perror(), etc.
#include <sys/ipc.h>                             // Inter-process communication
#include <sys/shm.h>                             // Shared memory
#include <sys/sem.h>                             // Semaphores
#include "ipc_data.h"                            // IPC Data structure
#include "writelog.h"                            // Log writer
#include "semops.h"                              // Semaphore operations
#include "sigcheck.h"                            // Signal processing
#include "adv_clock.h"                           // Clock advancement


#define DEBUGU 0                                 // Enable debugging = 1
#define IPCD_SZ (sizeof(ipcd_t))                 // Set the size of the IPC data structure


// MAIN
int main(int argc, char *argv[]) {

    // Local variables
    char msgerr[50] = "";                        // Hold a message to be passed to perror() or writelog()
    int shmid_ipcd;                              // Shared memory ID
    int signum;                                  // Hold a signal number
    ipcd_t *ipcd;                                // Pointer for shared memory
    int semid_clock, semid_memref;               // Clock and memory semaphore IDs
    int mypid, mynum;                            // My PID and child ID
    int SHMKEY, SEMKEY1, SEMKEY2;                // Shared memory and semaphore keys
    int sleep_secs;                              // Random sleep variable
    char procname[11] = "";                      // Procname variable to be passed to sem*() and writelog()
    int ref_count = 0, max_count;                // Counter for memory references

    // We need the process number as an argment
    if (argc != 2) {
        fprintf(stderr, "Process number was not passed in call to userproc\n");
        exit(1);
    } else {
        mynum = atoi(argv[1]);
    }

    srand(time(NULL));                           // Seed the random number generator

    mypid = getpid();                            // Get my process ID

    sprintf(procname, "userproc%02d", mynum);

    if (DEBUGU) printf("%s:\tmy PID is %d\n", procname, mypid);

    sprintf(msgerr, "Starting new run with PID %d", mypid);
    writelog(msgerr, procname);


    // /*
        // SHARED MEMORY ALLOCATION
    // */

    // Generate a shared memory key
    if ((SHMKEY = ftok(".", 47604000)) == -1) {
        sprintf(msgerr, "%s:\tftok (SHMKEY)", procname);
        perror(msgerr);
        exit(1);
    }

    // Generate a clock semaphore key
    if ((SEMKEY1 = ftok(".", 47604001)) == -1) {
        sprintf(msgerr, "%s:\tftok (SEMKEY1)", procname);
        perror(msgerr);
        exit(1);
    }

    // Generate a memory semaphore key
	int keyid = 47604010 + mynum;
    if ((SEMKEY2 = ftok(".", keyid)) == -1) {
        sprintf(msgerr, "%s:\tftok (SEMKEY2)", procname);
        perror(msgerr);
        exit(1);
    }

    // Get the ID of the shared IPC data
    if ((shmid_ipcd = shmget(SHMKEY, IPCD_SZ, 0600)) == -1) {
        sprintf(msgerr, "%s:\tshmget", procname);
        perror(msgerr);
        exit(1);
    }

    // Get a pointer to the shared IPC data segment
    if ( ! (ipcd = (ipcd_t *)(shmat(shmid_ipcd, 0, 0)))) {
        sprintf(msgerr, "%s:\tshmat", procname);
        perror(msgerr);
        exit(1);
    }
    writelog("Attached to shared memory for IPC data", procname);

    // Get a semaphore for the logical clock
    if ((semid_clock = semget(SEMKEY1, 1, 0600)) == -1) {
        sprintf(msgerr, "%s:\tsemget (clock)", procname);
        perror(msgerr);
        exit(1);
    }
    writelog("Attached to clock semaphore", procname);

    // Get a semaphore for memory references
    if ((semid_memref = semget(SEMKEY2, 1, 0600)) == -1) {
        sprintf(msgerr, "%s:\tsemget (memory)", procname);
        perror(msgerr);
        exit(1);
    }
    sprintf(msgerr, "Attached to memory reference semaphore (%d)", semid_memref);
    if (DEBUGU) printf("%s:\t%s\n", procname, msgerr);
    writelog(msgerr, procname);

    // /*
        // WORK LOOP
    // */

    max_count = 30 + ( rand() % 40 );          // random 50 +/- 20

    // Go into loop
    while (1) {

        // Check for signals
        if ( ( signum = sigcheck(procname) ) ) {
            sprintf(msgerr, "Received signal %d - exiting...", signum);
            writelog(msgerr, procname);
            break;
        }

        /*
            TERMINATION CHECK
        */

        if ( ref_count >= max_count ) {
            // Terminate myself
            ipcd->child_running[mynum] = -1;
            writelog("***** EXITING *****\n\n", procname);
            if (DEBUGU) printf("%s:\tExiting...\n", procname);
            exit(0);
        }
        if (DEBUGU) printf("%s:\tChild %02d has made %d memory references\n", procname, mynum, ref_count);

		// /*
            // GENERATE MEMORY REFERENCES
        // */

        ipcd->mem_references[mynum][0] = rand() % 32000;  // bytes 0-32000
        ipcd->mem_references[mynum][1] = rand() % 2;   // 0 for read, 1 for write
        ref_count++;

        if ( ipcd->mem_references[mynum][1] == 0 )
             sprintf(msgerr, "Generated read to memory location %d", ipcd->mem_references[mynum][0]);
        else
             sprintf(msgerr, "Generated write to memory location %d", ipcd->mem_references[mynum][0]);
        if (DEBUGU) printf("%s:\t%s\n", procname, msgerr);
        writelog(msgerr, procname);

        // Wait on memory reference semaphore (exit if interrupt received)
        sprintf(msgerr, "Waiting on memory semaphore");
        if (DEBUGU) printf("%s:\t%s\n", procname, msgerr);
        writelog(msgerr, procname);
        sem_op(SEMWAIT, semid_memref, procname); 

        // /*
            // SLEEP
        // */

        sleep_secs = rand() % 2;                 // Random from 0 to 1
        sprintf(msgerr, "Sleep %d", sleep_secs);
        writelog(msgerr, procname);
        if (DEBUGU) printf("%s:\t%s\n", procname, msgerr);
        sleep(sleep_secs);
    }

    return 0;
}
