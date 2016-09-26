// RCS DATA AT BOTTOM OF FILE

#include <stdio.h>                               // printf(), etc.
#include <stdlib.h>                              // exit()
#include <errno.h>                               // perror()
#include <sys/sem.h>                             // Semaphores

#include "sigcheck.h"                            // Signal processing

#ifndef _WL_INCLD                                // Check to see if writelog.h has already been included
    #include "writelog.h"                        // Log writer
    #define _WL_INCLD
#endif

#define DEBUGS 0                                 // Enable debugging = 1

// Semaphore operation function
void sem_op(int op, int semid, char *procname) {

    // op = -1 = wait, op = 1 = signal

    char msgerr[50] = "";                        // Hold a message to be passed to perror() or writelog()
    int signum;                                  // Hold a signal ID

    sprintf(msgerr, "sem_op (%d) called for semid %d, value is %d", op, semid, semctl(semid, 0, GETVAL));
    //writelog(msgerr, procname);
    if (DEBUGS) printf("%s: %s\n", procname, msgerr);

    struct sembuf sbuf;                          // Semaphore operation struct
    sbuf.sem_num = 0;                            // First (and only) semaphore in set
    sbuf.sem_op = op;                            // Increment/Decrement the semaphore
    sbuf.sem_flg = 0;                            // Operation flag
    if (semop(semid, &sbuf, 1) == -1)  {
        if (errno == EINTR) {
            // A signal was received, check it
            if ( ( signum = sigcheck(procname) ) ) {
                sprintf(msgerr, "Received signal %d - exiting...", signum);
                writelog(msgerr, procname);
                exit(0);
            }
        } else {
            sprintf(msgerr, "%s: sem_op (%d)->semop (semid: %d)", procname, op, semid);
            perror(msgerr);
            exit(1);
        }
    }

    sprintf(msgerr, "semid %d value has been updated to %d", semid, semctl(semid, 0, GETVAL));
    //writelog(msgerr, procname);
    if (DEBUGS) printf("%s: %s\n", procname, msgerr);

    return;
}

