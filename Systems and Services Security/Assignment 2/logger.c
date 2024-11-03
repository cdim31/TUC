#define _GNU_SOURCE

#include <time.h>
#include <stdio.h>
#include <dlfcn.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/stat.h>
#include <openssl/evp.h>
#include <errno.h>
#include <openssl/sha.h>  // Include SHA-256 from OpenSSL
#include "entry.h"

FILE * fopen(const char *path, const char *mode) 
{
	struct entry entry;
	
	entry.uid = getuid();
	// Initializing that access isn’t denied unless proven otherwise
	entry.action_denied = 0;
	time_t t = time(NULL);
	entry.time = *localtime(&t);
	memset(entry.fingerprint, 0, SHA256_DIGEST_LENGTH * 2 + 1);
	
	// Determine if the file exists
        int existed = access(path, F_OK) != -1;
	
	FILE *original_fopen_ret;
	FILE *(*original_fopen)(const char*, const char*);

	/* call the original fopen function */
	original_fopen = dlsym(RTLD_NEXT, "fopen");
	original_fopen_ret = (*original_fopen)(path, mode);


	// Converts the relative path to an absolute path using realpath and assigns it to entry.file
	char *abs_path = realpath(path, NULL);
    	if (!abs_path) {
        	perror("Failed to resolve absolute path");
        	abs_path = strdup(path);  // Fallback to original path
    	}
    	//strcpy(entry.file, abs_path);
    	entry.file = abs_path;
	// Checks if fopen succeeded for a file that doesn't exist
	if (original_fopen_ret != NULL && !existed){
		// Sets access type 0 for creation and gives an empty hash to fingerprint
		entry.access_type = 0;
		memcpy(entry.fingerprint, NULL_SHA256, SHA256_DIGEST_LENGTH*2 + 1);
	}
	// Checks if fopen succeeded for a file that exists
	else if (original_fopen_ret){
		// Sets access type 1 for successful open operation and computes the hash stored in fingerprint
		entry.access_type = 1;
		//get_md5(path, entry.fingerprint);
		get_sha256(path, entry.fingerprint);
	}
	// If file fails to open
	else {
		// Setting access_denied = 1 to indicate denied access and stores 0 in fingerprint
        	entry.action_denied = 1;
        	//memcpy(entry.fingerprint, "0", SHA256_DIGEST_LENGTH * 2 + 1);
        	memset(entry.fingerprint, '0', SHA256_DIGEST_LENGTH * 2);
		entry.fingerprint[SHA256_DIGEST_LENGTH * 2] = '\0';

        	/* Checks if the access mode is w, w+, a or a+ and if file does not exist
        	   - If condititon is true, sets access_type = 1 for the access attempt
        	   - If condition is false, sets access_type = 0 */
        	entry.access_type = (!strcmp(mode, "w") || !strcmp(mode, "w+") || !strcmp(mode, "a") || !strcmp(mode, "a+")) && !existed ? 1 : 0;
    	}
	
	// Writes log and frees the allocated memory for abs_path
	write_log(entry);
	free(abs_path);

	return original_fopen_ret;
}


size_t fwrite(const void *ptr, size_t size, size_t nmemb, FILE *stream) {

    /**
     * Create new entry struct and init the values we already know
     * We are writing so by default the access type is 2
     * uid is the current user
     * time is the current time
     */
    struct entry entry;
    entry.access_type = 2;
    entry.uid = getuid();
    time_t t = time(NULL);
    entry.time = *localtime(&t);
    memset(entry.fingerprint, 0, SHA256_DIGEST_LENGTH*2+1);

    /**
     * Get the current file descriptor and sequentialy the filename
     * grab the absolute path from the filename
     */
    int fd = fileno(stream);
    char proc_fd[255] = {0};
    char filename[255] = {0};
    sprintf(proc_fd, "/proc/self/fd/%d", fd);
    readlink(proc_fd, filename, 255);
    //strcpy(entry.file, realpath(filename, NULL));
    entry.file = realpath(filename, NULL);

	size_t original_fwrite_ret;
	size_t (*original_fwrite)(const void*, size_t, size_t, FILE*);

	/* call the original fwrite function */
	original_fwrite = dlsym(RTLD_NEXT, "fwrite");
	original_fwrite_ret = (*original_fwrite)(ptr, size, nmemb, stream);
    fflush(stream);
    /**
     * If the original fwrite returned 0 then we ere denied access
     * any value <= size means we wrote that many bytes so access was granted
     */
    if(!original_fwrite_ret){
        entry.action_denied = 1;
    }else{
        entry.action_denied = 0;
    }

    //get_md5(entry.file, entry.fingerprint);
    get_sha256(entry.file, entry.fingerprint);
    write_log(entry);
    free((void *)entry.file);
    return original_fwrite_ret;

}

FILE * fopen_original(const char *path, const char *mode){

    FILE *original_fopen_ret;
    FILE *(*original_fopen)(const char*, const char*);

    /* call the original fopen function */
    original_fopen = dlsym(RTLD_NEXT, "fopen");
    original_fopen_ret = (*original_fopen)(path, mode);

    return original_fopen_ret;
}

int get_sha256(const char *filename, char *output) {
    // Open the file in binary read mode using a function assumed to be
    // a custom fopen implementation that could involve specific error handling or logging.
    FILE *f = fopen_original(filename, "rb");
    if (!f) {
        // If the file can't be opened, print an error message and return a code indicating failure.
        fprintf(stderr, "Failed to open file: %s\n", filename);
        return -1;
    }

    // Create a new OpenSSL digest context for SHA-256 hashing.
    EVP_MD_CTX *mdctx = EVP_MD_CTX_new();
    if (!mdctx) {
        // If the context can't be created, close the file, print an error, and return.
        fclose(f);
        fprintf(stderr, "Failed to create digest context\n");
        return -2;
    }

    unsigned char md_value[EVP_MAX_MD_SIZE];  // Buffer to hold the resulting hash.
    unsigned int md_len;                     // Variable to hold the length of the hash.
    unsigned char buffer[1024];              // Buffer to hold file data for hashing.
    size_t bytes;

    // Initialize the digest context for SHA-256.
    if (EVP_DigestInit_ex(mdctx, EVP_sha256(), NULL) != 1) {
        // If initialization fails, clean up resources and return an error.
        fclose(f);
        EVP_MD_CTX_free(mdctx);
        fprintf(stderr, "Failed to initialize digest\n");
        return -3;
    }

    // Read from the file and update the digest incrementally.
    while ((bytes = fread(buffer, 1, sizeof(buffer), f)) > 0) {
        if (EVP_DigestUpdate(mdctx, buffer, bytes) != 1) {
            // If updating the digest fails, handle cleanup and error notification.
            fclose(f);
            EVP_MD_CTX_free(mdctx);
            fprintf(stderr, "Failed to update digest\n");
            return -4;
        }
    }

    // Finalize the digest, i.e., complete the hash computation.
    if (EVP_DigestFinal_ex(mdctx, md_value, &md_len) != 1) {
        // If finalization fails, perform cleanup and return an error.
        fclose(f);
        EVP_MD_CTX_free(mdctx);
        fprintf(stderr, "Failed to finalize digest\n");
        return -5;
    }

    // Close the file and free the digest context now that the hash is computed.
    fclose(f);
    EVP_MD_CTX_free(mdctx);

    // Convert the binary hash to a hexadecimal string.
    for (int i = 0; i < md_len; i++) {
        sprintf(output + (i * 2), "%02x", md_value[i]);
    }
    output[md_len * 2] = '\0';  // Null-terminate the output string to make it a proper C string.

    return 0;  // Return success.
}


void write_log(struct entry entry) {
    FILE *fp = fopen_original(LOG_FILE, "a");
    if (!fp) {
        fprintf(stderr, "Error opening log file.\n");
        return; // Exit the function if the file couldn't be opened.
    }

    fprintf(fp, "%d\t%s\t%d\t%d\t%02d-%02d-%d\t%02d:%02d:%02d\t%s\n",
            entry.uid, entry.file, entry.action_denied, entry.access_type,
            entry.time.tm_mday, entry.time.tm_mon + 1, entry.time.tm_year + 1900,
            entry.time.tm_hour, entry.time.tm_min, entry.time.tm_sec, entry.fingerprint);

    fclose(fp);
}


