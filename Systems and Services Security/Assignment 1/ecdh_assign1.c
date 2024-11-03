#include <stdio.h>
#include <stdlib.h>
#include <sodium.h>
#include <string.h>

// Helper function to print data as hexadecimal
void print_hex(FILE *f, const unsigned char *data, size_t len) {
    for (size_t i = 0; i < len; i++) {
        fprintf(f, "%02x", data[i]);
    }
    fprintf(f, "\n");
}


int main(int argc, char *argv[]) {
    if (sodium_init() < 0) {
        fprintf(stderr, "Failed to initialize libsodium\n");
        return 1;
    }

    unsigned char alice_private[crypto_box_SECRETKEYBYTES];
    unsigned char alice_public[crypto_box_PUBLICKEYBYTES];
    unsigned char bob_private[crypto_box_SECRETKEYBYTES];
    unsigned char bob_public[crypto_box_PUBLICKEYBYTES];
    unsigned char shared_secret_alice[crypto_scalarmult_BYTES];
    unsigned char shared_secret_bob[crypto_scalarmult_BYTES];

    int alice_provided = 0, bob_provided = 0;
    char *output_file = NULL;

    // Parse command-line arguments
    for (int i = 1; i < argc; i++) {
        if (strcmp(argv[i], "-o") == 0 && i + 1 < argc) {
            output_file = argv[i + 1];
            i++;
        } else if (strcmp(argv[i], "-a") == 0 && i + 1 < argc) {
            alice_provided = 1;
            unsigned long long a_private = strtoull(argv[i + 1], NULL, 10);
            memcpy(alice_private, &a_private, sizeof(a_private)); // Copy the integer value into the buffer
            i++;
        } else if (strcmp(argv[i], "-b") == 0 && i + 1 < argc) {
            bob_provided = 1;
            unsigned long long b_private = strtoull(argv[i + 1], NULL, 10);
            memcpy(bob_private, &b_private, sizeof(b_private)); // Copy the integer value into the buffer
            i++;
        } else if (strcmp(argv[i], "-h") == 0) {
            printf("Options:\n"
        		"-o path Path to output file\n"
			"-a number Alice's private key (optional)\n"
			"-b number Bob's private key (optional)\n"
			"-h This help message\n");
            return 0;
        }
    }

    // Generate or derive keys
    if (!alice_provided) {
        crypto_box_keypair(alice_public, alice_private);
    } else {
        crypto_scalarmult_base(alice_public, alice_private);
    }

    if (!bob_provided) {
        crypto_box_keypair(bob_public, bob_private);
    } else {
        crypto_scalarmult_base(bob_public, bob_private);
    }

    // Compute the shared secret (Alice's side)
    if (crypto_scalarmult(shared_secret_alice, alice_private, bob_public) != 0) {
        fprintf(stderr, "Error computing shared secret on Alice's side\n");
        return 1;
    }

    // Compute the shared secret (Bob's side)
    if (crypto_scalarmult(shared_secret_bob, bob_private, alice_public) != 0) {
        fprintf(stderr, "Error computing shared secret on Bob's side\n");
        return 1;
    }


    printf("Output written to %s\n", output_file);
    return 0;
}

