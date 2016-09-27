/* Kyu Cho
2750 project2
10/12/14
Description: HexDumper */
#include <stdio.h>
#include <stdlib.h>

void hexDump(unsigned char*, int);

int main(int argc, char *argv[]) {
	int i = 0;
	long SIZE;
	unsigned char *contents;
	size_t result;	

	FILE *iFile = fopen(argv[1], "rb"); //open file 
	if (iFile == NULL) { fputs("File error", stderr); exit(1); }
		
	fseek(iFile, 0, SEEK_END); // obtain file size:
	SIZE = ftell(iFile);
	rewind(iFile);
	
	contents = (char*)malloc(sizeof(char)*SIZE); // allocate memory to contain the whole file:
	if (contents == NULL) { fputs("Memory error", stderr); exit(2); }
	
	result = fread(contents, 1, SIZE, iFile); // copy the file into the contents:
	if (result != SIZE) { fputs("Reading error", stderr); exit(3); }

	hexDump(contents, SIZE);	
	fclose(iFile);
	free(contents);
	return 0;
}

void hexDump(unsigned char *contents, int SIZE) {
	int i;
	unsigned char *str = (char*)malloc(SIZE);
	
	for (i = 0; i < SIZE; i++) { // process every byte in the data		
		if ((i % 16) == 0) { // new line every 16 bytes(4 chars)
			if (i != 0) {
				printf("  %s\n", str);
			}			
			printf("  %04X: ", i); // output the offset in hex
		}		
		printf(" %02X", contents[i]); // the hex code for the specific character
		if (((contents[i] > 0x7e) || contents[i] < 0x20)) // print as a dot for unranged char
			str[i % 16] = '.';
		else
			str[i % 16] = contents[i]; // other wise insert the ch into str
		str[(i % 16) + 1] = '\0'; //restting the str 
	}	
	while ((i % 16) != 0) { // pad out last line if not exactly 16 characters
		printf("   ");
		i++;
	}
	printf("  %s\n", str);
}