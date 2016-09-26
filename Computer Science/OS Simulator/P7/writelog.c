// RCS DATA AT BOTTOM OF FILE

#include <stdio.h>                               // printf(), etc.
#include <stdlib.h>                              // exit()
#include <errno.h>                               // perror()
#include <time.h>                                // time()

// Log writer function
void writelog(char *msg, char *procname) {
    char msgerr[50] = "";                        // Hold a message

    // Set the log file name
    char logname[15] = "";
    sprintf(logname, "%s.log", procname);

    FILE *fp;
    if (!(fp = fopen(logname, "a"))) {
        sprintf(msgerr, "%s: opening %s", procname, logname);
        perror(msgerr);
        exit(1);
    }

    // Get the time
    time_t now;
    struct tm *timeinfo;
    time(&now);
    timeinfo = localtime(&now);

    // Write the time information to the log
    fprintf(fp, "%02d:%02d:%02d\t", timeinfo->tm_hour, timeinfo->tm_min, timeinfo->tm_sec);

    // Write the message to the log
    fprintf(fp, "%s:\t%s\n", procname, msg);

    // Close the log
    fclose(fp);
}

