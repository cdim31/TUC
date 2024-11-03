#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>

#define LOG_FILE "file_logging.log"

#define LOGS 10
#define USERS 10

int main() 
{

	FILE *file;

	char testFile_1[] = "testFile_1";
	char testFile_2[] = "testFile_2";

	char test_append[] = "O Dimas Kolompakis Kanei Test";
	char * real_path;

	char filenames[10][7] = {"file_0", "file_1", 
			"file_2", "file_3", "file_4",
			"file_5", "file_6", "file_7", 		
			"file_8", "file_9"};	

	char entasi[10][30] = {"DIMAS", "SARRIS", "VALSAMOS", "VOULGARIS", "STERGIOS", "TZEKOS", "EFI", "ZAMPON", "KOLOMPAKIS", "TestMaliciusUsers"};

	
	/* TESTING LOGGER */

	/* TEST 1*/
	/*
		Creating 10 files (file_0 to file_9) and write to them its name.
		Expecting logs:
			2 lines for each file:
				i) Access type flag 0 for creating and the empty file hash
				ii)Access type flag 2 for writing and the resulting hash
	*/

	for (int i = 0; i < 10; i++) {
		file = fopen(filenames[i], "w+");
		if (file == NULL) 
			printf("fopen error\n");
		else {
			fwrite(filenames[i], strlen(filenames[i]), 1, file);
			fclose(file);
		}
	}

	/* TEST 2 */
	/*
		Try to open files without having the permission to do so  
		Create 2 files and change file permissions to Deny Access
		Try to open them 4 times each.
		Expecting logs:
			i)  2 lines creating and the empty file hash
			ii) 2 lines for writting
			iii)8 lines deny access flag active (4 each) 

	*/
	file = fopen(testFile_1,"w+");
	if(file != NULL){
		fprintf(file, "Junks for File 1");
		fclose(file);
	}

	file = fopen(testFile_2,"w+");
	if(file != NULL){
		fprintf(file, "Junks for File 2");
		fclose(file);
	}

	chmod(testFile_1, 0);
	chmod(testFile_2, 0);

	for(int i=0;i<4;i++){
		file = fopen(testFile_1, "r");
		if(file != NULL)
			fclose(file);
		file = fopen(testFile_2, "r");
		if(file != NULL)
			fclose(file);
	}
	
	/* TEST 3 */
	/* 	Just an file open for reading
		Expecting logs:
			One line with the same hash as in Test 1

	/*
	 * Normal file opening
	 */
	file = fopen(filenames[4], "r");
	fclose(file);

	/* TEST 4 */
	/*  Check the append mode
		Expecting logs:
			i) 1 line with type of 1 and the same hash as in TEST one since the contents did not change
			ii) 1 line with access type of 2 and results in a different hash.

	 */
	file = fopen(filenames[2], "a");
	fwrite(test_append, sizeof(test_append), 1, file);
	fclose(file);


	/* TESTING MONITOR */

	file = fopen(LOG_FILE, "a");

	/*	TEST 1	*/

	/* Test malicius users*/

	/*
		Simulate users by creating different logs.
		Create 100 logs.
			-5 users try to acces 6 files each and denied access( set access denied flag to 1 ).
			-3 users try to acces 3 files each and denied acces.
		Expecting result:
			5 malicius users since the last 3 tried to access only 3 files (not 5 or more).

	*/
	for(int j=0;j<5;j++){
        for(int i=0;i<6;i++){
			real_path = realpath(filenames[i], NULL);
            fprintf(file,
            "%d\t%s\t%d\t%d\t%02d-%02d-%d\t%02d:%02d:%02d\t%s\n",
            j,real_path,1,1,93,5,93,5,93,5,"TestMaliciusUsers");
			free(real_path);
        }
    }

	for(int j=5;j<8;j++){
        for(int i=5;i<8;i++){
		real_path = realpath(filenames[i], NULL);
        	fprintf(file,
          "%d\t%s\t%d\t%d\t%02d-%02d-%d\t%02d:%02d:%02d\t%s\n",
           j,real_path,1,1,93,5,93,5,93,5,"TZEKOS");
			free(real_path);
        }
    }

	/*	TEST 2	*/
	
	/*  Test malicius users*/
	/*	Create 100 logs
		Write to the logfile 10 times for 10 users, 
		10 different hashes to simulate modifications
		Set filepath = file_8

		Expecting result (running the monitor with input file_8):
			11 lines where file_8 was modified 
			1 from user 1000 which was 
			in TEST 1 from the logger tests and 10 more lines for each user
	
	*/

	
	real_path = realpath(filenames[8], NULL);
	for(int j=0;j<USERS;j++){
        for(int i=0;i<LOGS;i++){
            fprintf(file,
            "%d\t%s\t%d\t%d\t%02d-%02d-%d\t%02d:%02d:%02d\t%s\n",
            j,real_path,0,2,93,5,93,5,93,5,entasi[i]);
        }
    }
	free(real_path);
	fclose(file);
	return 0;
}


