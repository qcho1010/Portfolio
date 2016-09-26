// #define 	idle	1	
// #define 	want_in	2
// #define 	in_cs	3

// #define 	not_ready	-1
// #define 	new_pellet_ckecked	0
// #define 	new_pellet	1
// #define 	terminate	2

// Shared memory
struct Memory {
	int n;
	int turn;
	int status;
	int fishX;
	int nTotal;
	int flag[20];
	int empty[20];
};

// Static memory for fish
struct Data {
	int empty;
	int pelletX;
	double totalDist;
};

// Static memory for pellet
struct Data2 {
	int pelletX;
	int pelletY;
	int eatten;
};

extern struct Data Data[20];
extern struct Data2 data2;
extern int ShmID;
extern int ShmID2;
extern int idArr[20];
extern double speed;
