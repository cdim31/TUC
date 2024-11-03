#define _GNU_SOURCE
#include <time.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <limits.h>

#include "entry.h"

struct log_entry {

	int uid; /* user id (positive integer) */
	int access_type; /* access type values [0-2] */
	int action_denied; /* is action denied values [0-1] */

	time_t date; /* file access date */
	time_t time; /* file access time */

	char *filename; /* filename (string) */
	char *fingerprint; /* file fingerprint */
	
	char *old_fingerprint; /* old fingerprint to check change*/

};


void usage(void)
{
	printf(
	       "\n"
	       "usage:\n"
	       "\t./monitor \n"
		   "Options:\n"
		   "-m, Prints malicious users\n"
		   "-i <filename>, Prints table of users that modified "
		   "the file <filename> and the number of modifications\n"
		   "-h, Help message\n\n"
		   );

	exit(1);
}


int get_lines(FILE * fp){
	int lines = 0;
	char ch;
	
	while(!feof(fp)){
		ch = fgetc(fp);
		if(ch == '\n')
			lines++;
	}
	rewind(fp);
	return lines;
}


void add_user(struct user *list, int uid, char *filename, int access_type){
	struct user * new = (struct user *)malloc(sizeof(struct user));
	struct user * tmp = list;

	while(tmp->next) tmp = tmp->next;

	tmp->next = new;
	new->uid = uid;
	new->access_type = access_type;
	new->access_fail = 1;
	new->next = NULL;

	memcpy(new->filenames[0], filename, PATH_MAX);
}


struct user * in_list(struct user *user, int uid){
	struct user * tmp = user;
	while (tmp){
		if (tmp->uid == uid) return tmp;
		tmp = tmp->next;
	}
	return NULL;
}


void handle_failure(struct user *user, char *file) {
	int exists = 0;

	if (!user || user->flagged) return;
	for (int i = 0; i<user->access_fail; i++){
		if (!strcmp(file, user->filenames[i])){
			exists = 1;
			break;
		}
	}
	if (!exists){
		memcpy(user->filenames[user->access_fail], file, PATH_MAX);
		user->access_fail++;
	}
	
	if (user->access_fail == 6) user->flagged = 1; 
}


void list_unauthorized_accesses(FILE *log) {
    struct log_entry entry;
    struct user *failures = NULL; // Head of the linked list tracking unauthorized access
    struct user *temp = NULL; // Temporary pointer for manipulation of linked list

    int lines = get_lines(log); // Get the total number of lines (entries) in the log

    for (int i = 0; i < lines; i++) {
        entry.filename = malloc(PATH_MAX); // Allocate memory for filename
        if (!entry.filename) {
            perror("Failed to allocate memory for filename");
            continue; // Skip this iteration if memory allocation fails
        }

        // Read log entry from file
        if (fscanf(log, "%d\t%s\t%d\t%d\t%*02d-%*02d-%*d\t%*02d:%*02d:%*02d\t%*s\n",
                   &entry.uid, entry.filename, &entry.action_denied, &entry.access_type) == 4) {
            // Check if the action was denied
            if (entry.action_denied) {
                // If no failures have been logged yet
                if (!failures) {
                    temp = (struct user *)malloc(sizeof(struct user)); // Allocate a new user node
                    if (!temp) {
                        perror("Failed to allocate memory for new user");
                        break;
                    }
                    // Initialize the new user node
                    temp->uid = entry.uid;
                    temp->access_type = entry.access_type;
                    temp->access_fail = 1;
                    memcpy(temp->filenames[0], entry.filename, PATH_MAX);
                    temp->next = NULL;
                    failures = temp; // Point head to the new node
                } else {
                    // Check if this user is already in the list
                    temp = in_list(failures, entry.uid);
                    if (temp == NULL) {
                        // Add new user to the list
                        add_user(failures, entry.uid, entry.filename, entry.access_type);
                    } else {
                        // Increment the failure count for existing user
                        handle_failure(temp, entry.filename);
                    }
                }
            }
        }

        free(entry.filename); // Free the dynamically allocated filename after use
    }

    // Output the list of users with unauthorized access
    temp = failures;
    
    while (temp) {
        if (temp->flagged) {
            printf("Malicious User (UID): %d\n", temp->uid);
        }
        temp = temp->next;
    }

    // Free the linked list
    while (failures) {
        temp = failures->next;
        free(failures);
        failures = temp;
    }
}


void list_file_modifications(FILE *log, char *file_to_scan) {
    struct log_entry entry;
    struct user *modifications = NULL;
    struct user *temp = NULL;

    char *real_path = realpath(file_to_scan, NULL); // Get the real path of the file to scan
    int lines = get_lines(log); // Get the total number of log entries

    for (int i = 0; i < lines; i++) {
        // Allocate memory for filename and fingerprints
        entry.filename = malloc(PATH_MAX);
        entry.fingerprint = malloc(SHA256_DIGEST_LENGTH * 2 + 1);
        entry.old_fingerprint = malloc(SHA256_DIGEST_LENGTH * 2 + 1);

        if (!entry.filename || !entry.fingerprint || !entry.old_fingerprint) {
            perror("Failed to allocate memory for filename or fingerprint");
            continue; // Skip this iteration if memory allocation fails
        }

        // Read log entry from file
        if (fscanf(log, "%d\t%s\t%d\t%d\t%*02d-%*02d-%*d\t%*02d:%*02d:%*02d\t%s\n",
                   &entry.uid, entry.filename, &entry.action_denied, &entry.access_type, entry.fingerprint) == 5) {
            // Check if file matches and there were modifications without denial
            if (!strcmp(entry.filename, real_path) && entry.access_type && !entry.action_denied &&
                (strncmp(entry.old_fingerprint, entry.fingerprint, SHA256_DIGEST_LENGTH * 2 + 1))) {
                memcpy(entry.old_fingerprint, entry.fingerprint, SHA256_DIGEST_LENGTH * 2 + 1);
                if (!modifications) {
                    // Allocate a new user node
                    temp = (struct user *)malloc(sizeof(struct user));
                    if (!temp) {
                        perror("Failed to allocate memory for new user");
                        break;
                    }
                    // Initialize the new user node
                    temp->uid = entry.uid;
                    temp->mods = 1;
                    temp->next = NULL;
                    modifications = temp;
                } else {
                    // Find or add the user to the modifications list
                    temp = in_list(modifications, entry.uid);
                    if (!temp) {
                        // Navigate to the end of the list and append a new user
                        temp = modifications;
                        while (temp->next) {
                            temp = temp->next;
                        }
                        temp->next = (struct user *)malloc(sizeof(struct user));
                        temp->next->uid = entry.uid;
                        temp->next->mods = 1;
                        temp->next->next = NULL;
                    } else {
                        // Increment modification count
                        temp->mods++;
                    }
                }
            }
        }

        // Free allocated memory
        free(entry.filename);
        free(entry.fingerprint);
        free(entry.old_fingerprint);
    }

    // Output the list of users with file modifications
    temp = modifications;
    while (temp) {
        printf("UID: %d\tMODS: %d\n", temp->uid, temp->mods);
        temp = temp->next;
    }

    // Free the modifications list
    while (modifications) {
        temp = modifications->next;
        free(modifications);
        modifications = temp;
    }

    free(real_path); // Free the real path
}



int main(int argc, char *argv[])
{

	int ch;
	FILE *log;

	if (argc < 2)
		usage();

	log = fopen("./file_logging.log", "r");
	if (log == NULL) {
		printf("Error opening log file \"%s\"\n", "./log");
		return 1;
	}

	while ((ch = getopt(argc, argv, "hi:m")) != -1) {
		switch (ch) {		
		case 'i':
			list_file_modifications(log, optarg);
			break;
		case 'm':
			list_unauthorized_accesses(log);
			break;
		default:
			usage();
		}

	}


	fclose(log);
	argc -= optind;
	argv += optind;	
	
	return 0;
}
