// RCS DATA AT END OF FILE

#define CHILD_MAX 18
#define MAX_RUNTIME 15
#define MAX_CHILD_MEM 32

// Data structure for page table
typedef struct {
    short page_tbl[CHILD_MAX][MAX_CHILD_MEM];    // Main page table
    unsigned int used[CHILD_MAX];                // 'used' bit vectors (one for each child)
    unsigned int dirty[CHILD_MAX];               // 'dirty' bit vectors (one for each child)
} pagetbl_t;

// Data structure for shared memory
typedef struct {
    unsigned int clock_sec;                      // Clock seconds
    unsigned int clock_milli;                    // Milliseconds since the last clock second
    unsigned int clock_nano;                     // Nanoseconds since the last clock second
    int child_running[CHILD_MAX];                // Run status of fork'd children
    pagetbl_t oss_paging;                        // Page table structure instance
    int mem_references[CHILD_MAX][2];            // Child memory references
} ipcd_t;
