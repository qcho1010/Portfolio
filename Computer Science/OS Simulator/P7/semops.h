// RCS DATA AT BOTTOM OF FILE

#define SEMWAIT -1                              // Argument for sem_op
#define SEMSIG 1                                // Argument for sem_op

// Semaphore operation function
void sem_op(int op, int semid, char *procname);
