// RCS DATA AT BOTTOM OF FILE


#include <stdio.h>                               // printf()
#include <stdlib.h>                              // exit()
#include <time.h>                                // time()
#include <wait.h>                                // wait()
#include <unistd.h>                              // sleep(), etc.
#include <errno.h>                               // perror()
#include <sys/ipc.h>                             // Inter-process communication
#include <sys/shm.h>                             // Shared memory
#include <sys/sem.h>                             // Semaphores
#include "ipc_data.h"                            // IPC Data structure
#include "writelog.h"                            // Log writer
#include "semops.h"                              // Semaphore operations
#include "sigcheck.h"                            // Signal processing
#include "adv_clock.h"                           // Clock advancement


#define DEBUGM 0                                 // Enable debugging = 1
#define IPCD_SZ sizeof(ipcd_t)                   // Size of the IPC data structure


// Global variables
int shmid_ipcd;                                  // Shared memory ID
ipcd_t *ipcd;                                    // Pointer for shared memory
int semid_clock;                                 // Semaphore ID for logical clock
int semid_memref[CHILD_MAX];                     // Semaphores for each child for memory references
char msgerr[50] = "";                            // Hold a message to be passed to perror() or writelog()
int child_pid[CHILD_MAX] = { 0 };                // Array of PIDs for child processes
int CHILD_RUN;                                   // Actual number of children to run
int wait_queue[CHILD_MAX];                       // Queue for processes waiting on page swap
int access_time[CHILD_MAX];                      // Hold effective memory access time for each process
unsigned int system_mem[8];                      // System memory allocation vectors
unsigned int mask;                               // Bitmask operator
unsigned int max_mask = 4294967295;              // Bitmask operator
int expnt;                                       // Exponent operator
int page;                                        // Temporary page calculator
int temp;                                        // Temporary page holder
int section;                                     // System memory section
short page_queue[CHILD_MAX][MAX_CHILD_MEM];      // Child FIFO page queues


// Function declarations/definitions

// Declaration for children counting function defined below
int count_children();

int term_proc(int child, int sig) {
    int status;                                  // Hold status from wait()

    sprintf(msgerr, "Attempting to terminate child %02d (PID %d)", child, child_pid[child]);
    if (DEBUGM) printf("oss:\t\t%s\n", msgerr);
    writelog(msgerr, "oss");

    kill(child_pid[child], sig);
    waitpid(child_pid[child], &status, WCONTINUED);

    sprintf(msgerr, "Child %02d returned %d", child, WEXITSTATUS(status));
    if (DEBUGM) printf("oss:\t\t%s\n", msgerr);
    writelog(msgerr, "oss");

    return WEXITSTATUS(status);
}

// Terminate all descendant processes and free shared memory
void cleanup(int termsig) {

    writelog("Executing cleanup()", "oss");

    // Terminate children
    int i;
    for (i = 0; i < CHILD_RUN; i++) {
        if ( ipcd->child_running[i] != 0 ) {
            if ( term_proc(i, termsig) != 0 ) {
                sprintf(msgerr, "There was an issue terminating child %02d", i);
                if (DEBUGM) printf("oss:\t\t%s\n", msgerr);
                writelog(msgerr, "oss");
            }
        }
    }

    // Release shared memory
    int ipcd_ret = shmctl(shmid_ipcd, IPC_RMID, (struct shmid_ds *)NULL);
    if (ipcd_ret != 0) fprintf(stderr, "Error releasing shared memory - please clear manually\n");
    else writelog("Released shared memory successfully", "oss");

    // Remove clock semaphore
    if ((semctl(semid_clock, 0, IPC_RMID, 1) == -1) && (errno != EINTR)) {
        sprintf(msgerr, "oss:\t\tcleanup->semctl (clock)");
        perror(msgerr);
    }
    else writelog("Removed clock semaphore successfully", "oss");

    // Remove memory reference semaphores
    for (i = 0; i < CHILD_RUN; i++) {
        if ((semctl(semid_memref[i], 0, IPC_RMID, 1) == -1) && (errno != EINTR)) {
            sprintf(msgerr, "oss:\t\tcleanup->semctl (semid_memref[%d])", i);
            perror(msgerr);
        } else {
            sprintf(msgerr, "Removed memory reference semaphore %d successfully", i);
            writelog(msgerr, "oss");
        }
    }

    // Print the final access statistics
    printf("\nFinal memory access times:\n\n");
    for (i = 0; i < CHILD_RUN; i++) {
        printf("Child %02d:\t%d nanoseconds\n", i, access_time[i]);
    }

    return;
}

int count_children() {
    int i, count = 0, j;

    //if (DEBUGM) printf("index\t\tchild_running array\t\tchild_pid array\n");
    for (i = 0; i < CHILD_RUN; i++) {
        //if (DEBUGM) printf("%02d\t\t\t%d\t\t\t%d\n",i,ipcd->child_running[i],child_pid[i]);

        // Check for child running status. If not, attempt to clear the process. If so, increment count.
        if ( ipcd->child_running[i] < 0 ) {
            sprintf(msgerr, "Child %02d (PID %d) has exited. Effective", i, child_pid[i]);
            sprintf(msgerr, "%s memory access time was %d ns", msgerr, access_time[i]);
            writelog(msgerr, "oss");
            
            if ( term_proc(i, SIGTERM) != 0 ) {
                sprintf(msgerr, "There was an issue terminating child %02d", i);
                if (DEBUGM) printf("oss:\t\t%s\n", msgerr);
                writelog(msgerr, "oss");
                cleanup(SIGTERM);
                exit(1);
            } else {
                // Release system memory pages allocated to this process
                //  We only need to worry about this if oss is still running, otherwise this section
                //  would be in termproc()
                for (j = 0; j < MAX_CHILD_MEM; j++) {
                    if ( ipcd->oss_paging.page_tbl[i][j] >= 0 ) {

                        // Determine the section of the page in system memory
                        temp = ipcd->oss_paging.page_tbl[i][j];

                        sprintf(msgerr, "Clearing allocated memory frame %d for child %02d", temp, i);
                        if (DEBUGM) printf("oss:\t\t%s\n", msgerr);
                        writelog(msgerr, "oss");

                        section = temp / 32;

                        // Determine the mask to use to clear the bit
                        mask = 1;
                        for (expnt = temp - (32 * section); expnt > 0; expnt--) mask *= 2;

                        // Clear system memory vector bit corresponding to the page in the page table
                        system_mem[section] = system_mem[section] & (max_mask - mask);
                    }
                }

                ipcd->child_running[i] = 0;
            }
        }

        // If this child is running, increment the total children count
        if ( ipcd->child_running[i] ) count++;
    }
    sprintf(msgerr, "Current child count is %d", count);
    writelog(msgerr, "oss");

    return count;
}

// Child forking function
void fork_child(int child) {
    char child_arg[3] = "";                      // String to hold child argument
    int j;

    if ((child_pid[child] = fork()) < 0) {
        sprintf(msgerr, "oss:\t\tfork() for child %02d", child);
        perror(msgerr);
        writelog("Error forking child", "oss");
        cleanup(SIGTERM);
        exit(1);
    } else {
        if (child_pid[child] == 0) {
            // exec child
            sprintf(child_arg, "%02d", child);
            execl("./userproc", "userproc", child_arg, (char *)NULL);

            // Handle execl() error, if one occurs
            sprintf(msgerr, "oss:\t\texec child %02d after fork", child);
            perror(msgerr);
        } else {
            // This is the parent; write to oss log about fork()
            sprintf(msgerr, "Forked process ID %d for child %02d", child_pid[child], child);
            writelog(msgerr, "oss");
            if (DEBUGM) printf("oss:\t\t%s\n", msgerr);
    
            // Initialize run parameters of child
            ipcd->child_running[child] = 1;
            for (j = 0; j < MAX_CHILD_MEM; j++) ipcd->oss_paging.page_tbl[child][j] = -1;
            ipcd->oss_paging.used[child] = 0;
            ipcd->oss_paging.dirty[child] = 0;
            ipcd->mem_references[child][0] = -1;
        }
    }
    return;
}

void upd_pg_tbl(int page, int child, int ms, int ns, int frame) {
    int i;

    // Update the page table with this childs reference to system memory (only if we have to load from disk)
    if ( frame >= 0 ) {
        ipcd->oss_paging.page_tbl[child][page] = frame;

        // Insert the referenced frame into the page queue
        for (i = 0; i < MAX_CHILD_MEM; i++) {
            if ( page_queue[child][i] < 0 ) page_queue[child][i] = frame;
            break;
        }
    }

    // Set used flag
    mask = 1;
    for (expnt = page; expnt > 0; expnt--) mask *= 2;
    ipcd->oss_paging.used[child] = ipcd->oss_paging.used[child] | mask;

    // Process write flag here
    if ( ipcd->mem_references[child][1] == 1 ) {
        // This is a page write - set dirty bit
        ipcd->oss_paging.dirty[child] = ipcd->oss_paging.dirty[child] | mask;
    }

    // Advance the logical clock
    sem_op(SEMWAIT, semid_clock, "oss");
    adv_clock(0, ms, ns, "oss");
    sem_op(SEMSIG, semid_clock, "oss");          // signal on clock semaphore

    ipcd->mem_references[child][0] = -1;         // Reset the memory reference indicator
    sprintf(msgerr, "Signalling memory semaphore for child %02d (%d)", child, semid_memref[child]);
    if (DEBUGM) printf("oss:\t\t%s\n", msgerr);
    writelog(msgerr, "oss");
    sem_op(SEMSIG, semid_memref[child], "oss");  // signal on memory reference semaphore
}

void enqueue(int child) {
    // Iterate through the queue from the beginning and place the pid in the first open slot
    int i;

    for (i = 0; i < CHILD_RUN; i++) {
        if ( wait_queue[i] == child ) {
            // Child is already waiting in the queue
            sprintf(msgerr, "Child %02d is already waiting in the queue", child);
            if (DEBUGM) printf("oss:\t\t%s\n", msgerr);
            writelog(msgerr, "oss");
            return;
        }
        if ( wait_queue[i] == -1 ) {
            sprintf(msgerr, "Page fault detected for child %02d - placing in queue slot %d", child, i);
            if (DEBUGM) printf("oss:\t\t%s\n", msgerr);
            writelog(msgerr, "oss");

            wait_queue[i] = child;
            return;
        } else {
            if ( i == CHILD_RUN - 1 ) {
                sprintf(msgerr, "Wait queue is full - waiting 15 ms");
                if (DEBUGM) printf("oss:\t\t%s\n", msgerr);
                writelog(msgerr, "oss");
                adv_clock(0, 15, 0, "oss");
            }
        }
    }

    return;
}

void dequeue() {
    // If there is no one in the queue, just return
    if ( wait_queue[0] == -1 ) return;
    if (DEBUGM) printf("oss:\t\tchild at the head of the queue is %02d\n", wait_queue[0]);

    int i, child, j, frame, k;

    child = wait_queue[0];

    // Allocate some system memory for this request
    for (i = 0; i < 8; i++) {
        for (j = 0; j < 32; j++) {
            if ( ((system_mem[i] >> j) & 1) == 0 ) {
                mask = 1;
                for (expnt = j; expnt > 0; expnt--) mask *= 2;
                //if (DEBUGM) printf("oss:\t\tmask at dequeue for child %02d is %u\n", child, mask);

                system_mem[i] = system_mem[i] | mask;
                page = ipcd->mem_references[child][0] / 1000;

                frame = (i * 32) + j;
                upd_pg_tbl(page, child, 15, 0, frame);

                sprintf(msgerr, "Child %02d has allocated system memory page %d", child, frame);
                if (DEBUGM) printf("oss:\t\t%s\n", msgerr);
                writelog(msgerr, "oss");

                // Update childs memory access time average
                access_time[child] = (access_time[child] + 15000000) / 2;

                // If the dequeue was successful, shift all members in the queue one position "lower"
                for (k = 0; k < CHILD_RUN; k++) {
                    if ( ( k + 1 ) == CHILD_RUN ) {
                        wait_queue[k] = -1;
                        break;
                    }
                    wait_queue[k] = wait_queue[k+1];
                    if ( wait_queue[k] == -1 ) break;
                    if (DEBUGM) printf("oss:\t\tdequeue: wait_queue[%d] = %d\n", k, wait_queue[k]);
                }
                if (DEBUGM) printf("oss:\t\tChild %02d has been dequeued\n", child);

                return;
            }

            // If we have not returned by now, we could not find an available memory frame
            if ( i == 7 && j == 31 ) {
                sprintf(msgerr, "System memory is exhausted - requeueing child %02d", child);
                writelog(msgerr, "oss");
                if (DEBUGM) printf("oss:\t\t%s\n", msgerr);
            }
        }
    }


    return;
}

// Page replacement paging algorithm
void page_replacement(int child, int page) {

    // Page replacement algorithm:
    //  Check the used bit for the page at the head of the queue
    //   If it is 0, page it out (simulate write-back if dirty flag set)
    //   If it is 1, move the page to the end of the queue and set the used flag to 0

    int i, k, page_moved = 0, slot_moved = 0;

    if ( page_queue[child][0] >= 0 ) {
        page_moved = page_queue[child][0];

        // Determine the slot in the page table that this is referring to
        for (i = 0; i < MAX_CHILD_MEM; i++) {
            if ( ipcd->oss_paging.page_tbl[child][i] == page_moved ) {
                slot_moved = i;
                break;
            }
        }

        // Calculate the section number for this page and the mask to use to clear/set it's bit
        section = page_moved / 32;
        mask = 1;
        for (expnt = page_moved - (32 * section); expnt > 0; expnt--) mask *= 2;

        //Determine if the used bit is set or not
        if ( ( ipcd->oss_paging.used[child] >> slot_moved & 1 ) == 0 ) {
            // Drop this page

            // If the page is dirty, write it back to disk (advance clock 15 ms)
            if ( ( ipcd->oss_paging.dirty[child] >> slot_moved & 1 ) == 1 ) {
                sprintf(msgerr, "Child %02d is writing dirty page %d back to disk", child, page_moved);
                if (DEBUGM) printf("oss:\t\t%s\n", msgerr);
                writelog(msgerr, "oss");
                adv_clock(0, 15, 0, "oss");
            }

            // Clear the bit int the system memory bit vector
            system_mem[section] = system_mem[section] & (max_mask - mask);

            // Remove the page from the page table
            sprintf(msgerr, "Child %02d is replacing page %d", child, page_moved);
            if (DEBUGM) printf("oss:\t\t%s\n", msgerr);
            writelog(msgerr, "oss");
            ipcd->oss_paging.page_tbl[child][slot_moved] = -1;

            // Rotate all pages forward in the queue starting from this location (insert page at end)
            for (k = 0; k < CHILD_RUN; k++) {
                if ( ( k + 1 ) == CHILD_RUN ) {
                    page_queue[child][k] = -1;
                    break;
                }
                page_queue[child][k] = page_queue[child][k+1];
            }
        } else {
            // Move the page to the rear of the queue and reset the used bit
            for (k = 0; k < CHILD_RUN; k++) {
                if ( ( k + 1 ) == CHILD_RUN ) {
                    page_queue[child][k] = page_moved;
                    break;
                }
                page_queue[child][k] = page_queue[child][k+1];
            }

            // Clear the used bit
            ipcd->oss_paging.used[child] = ipcd->oss_paging.used[child] & (max_mask - mask);
            if (DEBUGM) printf("oss:\t\tThe clear used mask (child %02d) is %X\n", child, (max_mask - mask));

            sprintf(msgerr, "Page replacement has moved frame %d for child ", page_moved);
            sprintf(msgerr, "%s %02d to the rear of the page queue", msgerr, child);
            if (DEBUGM) printf("oss:\t\t%s\n", msgerr);
            writelog(msgerr, "oss");
        }
    }

    if ( ipcd->oss_paging.page_tbl[child][page] < 0 ) {
        // This is a page fault
        enqueue(child);
    } else {
        // Page is already in memory - advance clock 10 ns and signal the child's memory semaphore
        sprintf(msgerr, "Child %02d's request for address %d", i, ipcd->mem_references[child][0]);
        sprintf(msgerr, "%s is already in memory", msgerr);
        if (DEBUGM) printf("oss:\t\t%s\n", msgerr);
        writelog(msgerr, "oss");

        upd_pg_tbl(page, child, 0, 10, -1);

        // Update childs memory access time average
        access_time[child] = (access_time[child] + 10) / 2;
    }

     return;
}


// MAIN
int main(int argc, char *argv[]) {

    // Local variables
    int child_sel;                               // Selected child to fork
    int SHMKEY;                                  // Shared memory key
    int SEMKEY1;                                 // Semaphore key (clock)
    int sleep_secs;                              // Random sleep variable
    int i, j;                                    // Iteration variables
    int signum;                                  // Hold a signal number
    unsigned int next_fork_sec = 0;              // Time of next fork second
    unsigned int next_fork_msec = 0;             // Time of next fork millisecond

    // Process command line argument
    if (argc == 1) CHILD_RUN = 12;
    else {
        if ( ( CHILD_RUN = atoi(argv[1]) ) > CHILD_MAX ) {
            CHILD_RUN = CHILD_MAX;
            printf("\n\n\tNOTE: You have entered an argument value greater than the maximum\n");
            printf("\tnumber of processes that this program can run concurrently. The\n");
            printf("\tprogram will now run with a maximum concurrency of %d.\n\n", CHILD_RUN);
            printf("\tPress the ENTER key to continue...\n\n");
            getchar();
        }
    }

    sprintf(msgerr, "The max number of processes will be: %d", CHILD_RUN);
    if (DEBUGM) printf("oss:\t\t%s\n", msgerr);
    writelog(msgerr, "oss");

    
    if ( DEBUGM ) printf("oss:\t\tThe size of the shared data structure is %ld bytes\n", IPCD_SZ);

    srand(time(NULL));                           // Seed the random number generator

    // /*
        // SHARED MEMORY ALLOCATION
    // */

    // Generate a shared memory key
    if ((SHMKEY = ftok(".", 47604000)) == -1) {
        perror("oss:\t\tftok (SHMKEY)");
        exit(1);
    }

    // Generate a semaphore key for clock
    if ((SEMKEY1 = ftok(".", 47604001)) == -1) {
        perror("oss:\t\tftok (SEMKEY1)");
        exit(1);
    }

    // Allocate memory for the shared IPC data
    shmid_ipcd = shmget(SHMKEY, IPCD_SZ, 0600 | IPC_CREAT);
    if (shmid_ipcd == -1) {
        perror("oss:\t\tshmget");
        exit(1);
    }

    // Get a pointer to the shared IPC data segment
    if ( ! (ipcd = (ipcd_t *)(shmat(shmid_ipcd, 0, 0)))) {
        sprintf(msgerr, "oss:\t\tshmat");
        perror(msgerr);
        exit(1);
    }

    writelog("Allocated and attached to shared memory for IPC data", "oss");

    // Get a semaphore for the logical clock
    if ((semid_clock = semget(SEMKEY1, 1, 0600 | IPC_CREAT)) == -1) {
        sprintf(msgerr, "oss:\t\tsemget (clock)");
        perror(msgerr);
        exit(1);
    }
    sprintf(msgerr, "Clock semaphore ID is %d", semid_clock);
    writelog(msgerr, "oss");
    if (DEBUGM) printf("oss:\t\t%s\n", msgerr);

    // Initialize the clock semaphore
    union semun { int val; struct semid_ds *buf; ushort * array; } argument;
    argument.val = 1;                            // Set the semaphore value to one
    if (semctl(semid_clock, 0, SETVAL, argument) == -1) {
        sprintf(msgerr, "oss:\t\tsemctl (clock)");
        perror(msgerr);
        exit(1);
    }
    writelog("Created and initialized clock semaphore to 1", "oss");

    // Initialize the logical clock
    sem_op(SEMWAIT, semid_clock, "oss");         // wait on clock semaphore
    ipcd->clock_sec = 0;
    ipcd->clock_nano = 0;
    sem_op(SEMSIG, semid_clock, "oss");          // signal on clock semaphore
    sprintf(msgerr, "Initialized clock");
    writelog(msgerr, "oss");


    // Create and initialize semaphores for memory access
    int SEMKEY[CHILD_RUN];
    for (i = 0; i < CHILD_RUN; i++) {
        // Create a semaphore key
        int keyid = 47604010 + i;
        if ((SEMKEY[i] = ftok(".", keyid)) == -1) {
            sprintf(msgerr, "oss:\t\tftok (SEMKEY[%d])", i);
            perror(msgerr);
            exit(1);
        }

        // Create the semaphore
        if ((semid_memref[i] = semget(SEMKEY[i], 1, 0600 | IPC_CREAT)) == -1) {
            sprintf(msgerr, "oss:\t\tsemget (SEMKEY[%d])", i);
            perror(msgerr);
            exit(1);
        }

        // Initialize the semaphore
        union semun { int val; struct semid_ds *buf; ushort * array; } argument;
        argument.val = 0;                        // Set the semaphore value to zero
        if (semctl(semid_memref[i], 0, SETVAL, argument) == -1) {
            sprintf(msgerr, "oss:\t\tsemctl (SEMKEY[%d])", i);
            perror(msgerr);
            exit(1);
        }

        sprintf(msgerr, "Created and set memory semaphore for child %02d (%d) to 0", i, semid_memref[i]);
        writelog(msgerr, "oss");
    }


    // Initialize the child run status array, wait_queue, page queues, and access times
    for (i = 0; i < CHILD_MAX; i++) {
        ipcd->child_running[i] = 0;
        wait_queue[i] = -1;
        for (j = 0; j < MAX_CHILD_MEM; j++) page_queue[i][j] = -1;
        access_time[i] = 0;
    }
    writelog("Initialized child run status array and wait_queue", "oss");


    // Initialize the allocated system memory bit vectors
    for (i = 0; i < 4; i++) system_mem[i] = 0;

    sprintf(msgerr, "Initialized memory management structures");
    if (DEBUGM) printf("oss:\t\t%s\n", msgerr);
    writelog(msgerr, "oss");

    // /*
        // WORK SECTION
    // */

    while (1) {

        // Check for signals
        if ( ( signum = sigcheck("oss") ) ) {
            cleanup(signum);                     // Call cleanup with whatever the signal was
            break;
        }

        /*
            FORK AND EXEC CHILDREN
        */

        // Only attempt a fork another child if we are below CHILD_RUN processes
        if ( ipcd->clock_sec >= next_fork_sec && ipcd->clock_milli >= next_fork_msec ) {
            if ( count_children() < CHILD_RUN ) {

                // Determine which child to fork
                for (i = 0; i <= CHILD_RUN; i++) {
                    if ( ipcd->child_running[i] == 0 ) {
                        child_sel = i;
                        break;
                    }
                }

                sprintf(msgerr, "Selected child number %02d to fork", child_sel);
                writelog(msgerr, "oss");

                fork_child(child_sel);
            }
            next_fork_msec = ipcd->clock_milli + ( 1 + ( rand() % 500 ) );
            if ( next_fork_msec >= 1000 ) {
                next_fork_sec++;
                next_fork_msec -= 1000;
            }
        }

        // /*
            // MEMORY MANAGEMENT
        // */

        // Check the wait queue
        if (DEBUGM) {
            printf("oss:\t\tChecking wait queue...\n");
            for (i = 0; i < CHILD_RUN; i++) printf("oss:\t\twait_queue[%d] = %d\n", i, wait_queue[i]);
        }
        dequeue();

        // Check for memory references
        for (i = 0; i < CHILD_RUN; i++) {
            if ( ipcd->child_running[i] > 0 && ipcd->mem_references[i][0] >= 0 ) {
                page = ipcd->mem_references[i][0] / 1000;  // The high-order portion of address is the page

                sprintf(msgerr, "Child %02d requests address", i);
                sprintf(msgerr, "%s %d (page %d)", msgerr, ipcd->mem_references[i][0], page);
                if (DEBUGM) printf("oss:\t\t%s\n", msgerr);
                writelog(msgerr, "oss");

                page_replacement(i, page);
            }
        }

        // Simulate 15 ms device wait by advancing the clock
        adv_clock(0, 15, 0, "oss");

        sprintf(msgerr, "Logical clock is now %d.%03d", ipcd->clock_sec, ipcd->clock_milli);
        sprintf(msgerr, "%s.%03d", msgerr, ipcd->clock_nano);
        writelog(msgerr, "oss");
        if (DEBUGM) printf("oss:\t\t%s\n", msgerr);

        // Break if we have reached MAX_RUNTIME elapsed (logical) seconds
        if (ipcd->clock_sec >= MAX_RUNTIME) {
            sprintf(msgerr, "Reached maximum run time - exiting.");
            writelog(msgerr, "oss");
            if (DEBUGM) printf("oss:\t\t%s\n", msgerr);
            cleanup(SIGINT);
            break;
        }

        // Print memory map
        printf("System memory pages allocated (1k pages, 1 = allocated, 0 = available):\n");
        printf("Pages\tPages\tPages\tPages\tPages\tPages\tPages\tPages\n");
        printf("0-31\t32-63\t64-95\t96-127\t128-159\t160-191\t192-223\t224-255\n");
        for (i = 0; i < 32; i++) {
            printf("  %d\t  %d\t", ((system_mem[0] >> i) & 0x1), ((system_mem[1] >> i) & 0x1));
            printf("  %d\t  %d\t", ((system_mem[2] >> i) & 0x1), ((system_mem[3] >> i) & 0x1));
            printf("  %d\t  %d\t", ((system_mem[4] >> i) & 0x1), ((system_mem[5] >> i) & 0x1));
            printf("  %d\t  %d\n", ((system_mem[6] >> i) & 0x1), ((system_mem[7] >> i) & 0x1));
        }

        // Write log entry and sleep
        sleep_secs = rand() % 2;                 // Random from 0 to 1
        sprintf(msgerr, "Sleep %d", sleep_secs);
        writelog(msgerr, "oss");
        sleep(sleep_secs);
    }


    return 0;
}