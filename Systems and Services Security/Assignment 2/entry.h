#ifndef EXERCISE_2_ENTRY_H
#define EXERCISE_2_ENTRY_H

#include <time.h>
#include <limits.h>
#include <openssl/sha.h>  // Include SHA-256 from OpenSSL

#define NULL_SHA256 "E3B0C44298FC1C149AFBF4C8996FB92427AE41E4649B934CA495991B7852B855"
#define EMPTY_SHA256 "E3B0C44298FC1C149AFBF4C8996FB92427AE41E4649B934CA495991B7852B855"

#define LOG_FILE "file_logging.log"

struct entry {
    int uid; /* user id (positive integer) */
    int access_type; /* access type values [0-2] */
    int action_denied; /* is action denied values [0-1] */
    struct tm time;
    const char *file; /* filename (string) */
    char fingerprint[SHA256_DIGEST_LENGTH*2 +1]; /* file fingerprint using SHA-256 */
};

struct user {
    int uid;
    int access_fail;
    int flagged;
    int access_type;
    int mods;
    char filenames[10][PATH_MAX];
    struct user * next;
};

struct user * in_list(struct user *, int);
void add_user(struct user *, int, char *, int);
void handle_failure(struct user *, char *);
int get_sha256(const char *, char *);
void write_log(struct entry);

#endif // EXERCISE_2_ENTRY_H
