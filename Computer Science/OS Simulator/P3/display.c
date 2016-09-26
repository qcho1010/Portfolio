#include <sys/types.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <math.h>
#include "swim_mill.h"

void process (char ShmPTR[23][23], struct Memory *ShmPTR2, int i, int fishORpellet);
void critical_section_fish (char ShmPTR[23][23], struct Memory *ShmPTR2);
void critical_section_pellet (char ShmPTR[23][23], struct Memory *ShmPTR2);
int findPellet(char ShmPTR[23][23], struct Memory *ShmPTR2, int fishX);
void updatePos(char ShmPTR[23][23], int x, struct Memory *ShmPTR2, int fishX);
void display(char ShmPTR[23][23]);

struct Data data[20];
struct Data2 data2;
double speed;

void process (char ShmPTR[23][23], struct Memory *ShmPTR2, int i, int fishORpellet) {
	int k, maxIndex, index = 0; // Local to each process 0..n
	int n = ShmPTR2->n;
	do {
		ShmPTR2->flag[i] = 2; // Raise my flag		
		index  = ShmPTR2->turn;		// Next Turn is selected from previous iteration
		while (index != i) {		// Check if you are eligible to have "turn" title 
			if(ShmPTR2->flag[index] != 1) 	// Stay in the loop untill all other flags becomes idle till your 'i' index
				index = ShmPTR2->turn;		// If they found non-idle flag, reset the index to go though the loop again
			else
				index = (index+1)%n;		// If they found idle flag, move to next flag
		}
		ShmPTR2->flag[i] = 3;	// Since all of flag are idle, declear you will be in CS

		for (index=0; index<n; index++)		// But one more time to check whole flag before actually getting in
			if (index != i && ShmPTR2->flag[index] == 3)		// If they found process in CS, this, do while loop continues
				break;			// Its important to make sure that non of flags are in CS to avoid the infinite loop
	} while ((ShmPTR2->turn != i && ShmPTR2->flag[ShmPTR2->turn] != 1 ) || index < n);
	ShmPTR2->turn = i;		// Declear it's your turn

	if (fishORpellet == 1) 
		critical_section_fish(ShmPTR, ShmPTR2);
	else if (fishORpellet == 0) 
		critical_section_pellet(ShmPTR, ShmPTR2);
	
	index = ((ShmPTR2->turn)+1)%n;		// Move to next index to check if there is any non idle flag
	while (ShmPTR2->flag[index] == 1) 	// Just skip idle flag
		index = (index+1)%n;
	
	ShmPTR2->turn = index; // Found non idle flag, and store its index to 'turn' for next iteration
	ShmPTR2->flag[i] = 1; // Make myself idle.
}

void critical_section_fish (char ShmPTR[23][23], struct Memory *ShmPTR2) {
	int fishX = ShmPTR2->fishX;
	if(ShmPTR2->status == 1) {		// go for new pellet
		ShmPTR2->status = 0;
		data->pelletX = findPellet(ShmPTR, ShmPTR2, fishX); 		// Find the cloest pelletX
	}
	updatePos(ShmPTR, data->pelletX, ShmPTR2, fishX);	//  Change the position
	
	display(ShmPTR);	
}

void critical_section_pellet (char ShmPTR[23][23], struct Memory *ShmPTR2) {
	int i = 0x80;
	int pelletX = data2.pelletX;
	int pelletY = data2.pelletY;
	
	if(ShmPTR[pelletY+1][pelletX] == 'P') {		// fish infront of you
		data2.pelletY++;
		data2.eatten = 1;
		ShmPTR2->status = 1;
		ShmPTR[pelletY][pelletX] = '.';
	} else if((pelletY+1) == 23) {		// outof bound
		data2.eatten = 1;
		ShmPTR[pelletY][pelletX] = '.';
	} else {			// still moving
		data2.pelletY++;
		pelletY++;
		ShmPTR[pelletY][pelletX] = i;	
		ShmPTR[pelletY-1][pelletX] = '.';
	}
	display(ShmPTR);	
}

int findPellet(char ShmPTR[23][23], struct Memory *ShmPTR2, int X) {
	int x,y,j, fishX = X;
	double totalDist;
	char i = 0x80;	
	for(y=0; y<23; y++){
		for(x=0; x<23; x++) {
			if(ShmPTR[y][x] == i && abs(fishX-x) <= abs(22-y)*2) { 		// Check if the dopped pellet is reachable
				totalDist = speed + abs(fishX-x)*-1 + abs(22-y)*2 + sqrt(abs(fishX-x)^2+abs(22-y)^2);		// Calculate the pts;
				for(j=0; j<20; j++) {
					if(data[j].empty == 0) {
						data[j].totalDist = totalDist;
						data[j].pelletX = x;
						data[j].empty = 1;
						break;
					}
				}	
			}
		}
	}
	
	int pelletX = 11, index = 0;
	double min;
	min = data[0].totalDist;
	j = 0;
	while (data[j].empty == 1 && j < 20) {
		if (data[j+1].totalDist < min) {
			min = data[j+1].totalDist;	
			pelletX = data[j].pelletX;
			index = j;
		}
		data[j].totalDist = 0;
		data[j].pelletX = 0;		
		data[j].empty = 0;	
		j++;
	}
	return pelletX;
}

void updatePos(char ShmPTR[23][23], int x, struct Memory *ShmPTR2, int X) {
	int j, fishX = X;
	char i = 0x80;
	
	// Obtain fishX
	if (fishX != x) { 		//and pellet isn't eatten;
		ShmPTR[22][fishX] = '.';	
		if (fishX < x) {
			fishX++;
			ShmPTR2->fishX++;
		}	else {
			fishX--;
			ShmPTR2->fishX--;
		}
	}
	ShmPTR[22][fishX] = 'P';	
}

void display(char ShmPTR[23][23]) {
	system("clear");
	int x, y;
	for (y=0; y<23; y++) {
		for (x=0; x<23; x++) {
			printf("%c ", ShmPTR[y][x]);
		}
		printf("\n");
	}	
	printf("\n");
}
