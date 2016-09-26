// RCS DATA AT BOTTOM OF FILE

#include <stdio.h>                               // fprintf()
#include <signal.h>                              // signal()

// Global variables
int signum;                                      // Hold a signal number

// Catch signals
void sigproc(int sig) {
    signum = sig;
}

// Process signals
int sigcheck(char *procname) {
    signal(SIGINT, sigproc);
    signal(SIGTERM, sigproc);
    if (signum == 2 || signum == 15) {
        if (signum == 2) fprintf(stderr, "%s: Caught CTRL-C (SIGINT)\n", procname);
        else if (signum == 15) fprintf(stderr, "%s: Caught SIGTERM\n", procname);
        return signum;
    }
    return 0;
}
