/* Kyu Cho
2750 project2
10/12/14
Description: HexDumper */

#include <stdio.h>
#include <stdlib.h>

void hexDump(unsigned char*, int, char *);

int main(int argc, char *argv[]) {
	int i = 0;
	long SIZE;
	unsigned char *contents;
	size_t result;

	//open file 
	FILE *iFile = fopen(argv[1], "rb");

	if (iFile == NULL) { fputs("File error", stderr); exit(1); }

	// obtain file size:
	fseek(iFile, 0, SEEK_END);
	SIZE = ftell(iFile);
	rewind(iFile);

	// allocate memory to contain the whole file:
	contents = (char*)malloc(sizeof(char)*SIZE);
	if (contents == NULL) { fputs("Memory error", stderr); exit(2); }

	// copy the file into the contents:
	result = fread(contents, 1, SIZE, iFile);
	if (result != SIZE) { fputs("Reading error", stderr); exit(3); }

	hexDump(contents, SIZE, argv[1]);

	return 0;
	fclose(iFile);
	free(contents);
}

void hexDump(unsigned char *contents, int SIZE, char *fileName) {
	int i;
	unsigned char *str;
	str = (char*)malloc(SIZE);
	FILE *oFile = fopen("result.txt", "w");

	// process every byte in the data
	for (i = 0; i < SIZE; i++) {
		// new line every 16 bytes(4 chars)
		if ((i % 16) == 0) {
			if (i != 0) {
				printf("  %s\n", str);
				fprintf(oFile, "  %s\n", str);
			}
			// output the offset in hex
			printf("  %04X: ", i);
			fprintf(oFile, "  %04X: ", i);
		}
		// the hex code for the specific character
		printf(" %02X", contents[i]);
		fprintf(oFile, " %02X", contents[i]);
		if (((contents[i] > 0x7e) || contents[i] < 0x20)) // print as a dot for unranged char
			str[i % 16] = '.';
		else
			str[i % 16] = contents[i]; // other wise insert the ch into str
		str[(i % 16) + 1] = '\0'; //restting the str 
	}
	// pad out last line if not exactly 16 characters
	while ((i % 16) != 0) {
		printf("   ");
		fprintf(oFile, "   ");
		i++;
	}
	// Print last string
	printf("  %s\n", str);
	fprintf(oFile, "   ");
	fclose(oFile);
}