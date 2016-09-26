#include <stdio.h>                               // printf()
#include <stdlib.h>                              // exit()
#include <time.h>                                // time()
#include <wait.h>                                // time()
#include <unistd.h>                              // sleep(), etc.
#include <errno.h>                               // perror()
#include <sys/ipc.h>                             // Inter-process communication
#include <sys/shm.h>                             // Shared memory
#include <sys/sem.h>                             // Semaphores

#define maxChild 18
#define resMax 20
#define instMax 10
#define IPCD_SZ sizeof(ShmPTR_t)                   // Size of the IPC data structure

// Data structure for resource descriptors
typedef struct {
    int inst_tt;                                // How many total instances of this resource
    int inst_avail;                              // How many available instances of this resource
    int shared;                                  // Resource shared indicator
    int max_claim[maxChild];                    // Max claims by child number
    int request[maxChild];                      // Requests by child number
    int allocated[maxChild];                    // Allocation by child number
    int release[maxChild];                      // Releases notices by child number
} resource_t;

// Data structure for shared memory
typedef struct {
    unsigned int secTime;                      // Clock seconds
    unsigned int milliTime;                    // Milliseconds since the last clock second
    unsigned int nanoTime;                     // Nanoseconds since the last clock second
    resource_t resources[resMax];               // Array of resource descriptors
    int childTaken[maxChild];                // Run status of fork'd children
    int throughput[maxChild];                   // Counter for child throughput
    int wait_time[maxChild];                    // Accumulator for child wait time
    unsigned long cpu_util[maxChild];           // Accumulator for child CPU time
} ShmPTR_t;
