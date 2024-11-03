#include <stdio.h>
#include <gmp.h>
#include <math.h>
#include <stdlib.h> 	
#include <unistd.h>   
#include <stdbool.h>  
#include <string.h>
#include <sys/time.h>
#include <time.h>
#include <sys/resource.h>

// Function to compute the greatest common divisor (GCD)
void gcd(mpz_t result, const mpz_t a, const mpz_t b) {
    mpz_gcd(result, a, b);
}


// Function to compute the modular inverse of e mod lambda
void mod_inverse(mpz_t result, const mpz_t e, const mpz_t lambda) {
    mpz_invert(result, e, lambda);  // result = e^(-1) mod lambda
}


void generateRSAKeyPair(int length) {
    mpz_t p, q, n, lambda_n, e, d, gcd_result, p_1, q_1;
    int key_length = length;

    // Initialize GMP variables
    mpz_inits(p, q, n, lambda_n, e, d, gcd_result, p_1, q_1, NULL);

    // Step 1: Generate large primes p and q, each of key_length / 2 bits
    int prime_bits = key_length / 2;
    // Generate large primes p and q
    do {
        gmp_randstate_t state;
    	gmp_randinit_default(state);
    	mpz_urandomb(p, state, prime_bits / 2);  // Random prime p (bits/2 size)
    	mpz_nextprime(p, p);
    	mpz_urandomb(q, state, prime_bits / 2);  // Random prime q (bits/2 size)
    	mpz_nextprime(q, q);
    } while ((mpz_probab_prime_p(p, 25) == 0) || (mpz_probab_prime_p(q, 25) == 0));  // Ensure it's prime

    // Step 2: Compute n = p * q
    mpz_mul(n, p, q);

    // Step 3: Compute lambda(n) = (p - 1) * (q - 1)
    mpz_sub_ui(p_1, p, 1);  // p - 1
    mpz_sub_ui(q_1, q, 1);  // q - 1
    mpz_mul(lambda_n, p_1, q_1);  // lambda(n)

    // Step 4: Choose a prime e such that 1 < e < lambda(n) and gcd(e, lambda(n)) == 1
    mpz_set_ui(e, 65537);  // Common choice for e in RSA
    gcd(gcd_result, e, lambda_n);

    if (mpz_cmp_ui(gcd_result, 1) != 0) {
        printf("Error: gcd(e, lambda_n) != 1\n");
        mpz_clears(p, q, n, lambda_n, e, d, gcd_result, p_1, q_1, NULL);
        exit(EXIT_FAILURE);
    }

    // Step 5: Compute d, the modular inverse of e mod lambda(n)
    mod_inverse(d, e, lambda_n);
   
    char filename1[50];
    char filename2[50];
   
    // Step 6: Write public key (n, e)
    FILE * publicKeyFile;
    sprintf(filename1, "public_%d.key", length);
    publicKeyFile = fopen(filename1, "w");
    if (publicKeyFile == NULL) {
        perror("Failed to open public key file");
        mpz_clears(p, q, n, lambda_n, e, d, gcd_result, p_1, q_1, NULL);
        exit(EXIT_FAILURE);
    }
    // Write n and e as hexadecimal
    gmp_fprintf(publicKeyFile, "%Zx,%Zx\n", n, e);
    fclose(publicKeyFile);

    // Step 7: Write private key (n, d)
    FILE * privateKeyFile;
    sprintf(filename2, "private_%d.key", length);
    privateKeyFile = fopen(filename2, "w");
    if (privateKeyFile == NULL) {
        perror("Failed to open private key file");
        mpz_clears(p, q, n, lambda_n, e, d, gcd_result, p_1, q_1, NULL);
        exit(EXIT_FAILURE);
    }
    // Write n and d as hexadecimal
    gmp_fprintf(privateKeyFile, "%Zx,%Zx\n", n, d);
    fclose(privateKeyFile);

    // Step 8: Output the public key (n, e) and private key (n, d)
    gmp_printf("Public Key (n, e): \nn = %Zd\ne = %Zd\n", n, e);
    gmp_printf("Private Key (n, d): \nn = %Zd\nd = %Zd\n", n, d);

    // Clear memory
    mpz_clears(p, q, n, lambda_n, e, d, gcd_result, p_1, q_1, NULL);
}


void encryptRSA(char* plaintext, char* ciphertext, char* publicKey) {
    FILE *plaintextFile, *ciphertextFile, *publicKeyFile;
   
    // Open files for reading and writing
    plaintextFile = fopen(plaintext, "r");
    publicKeyFile = fopen(publicKey, "r");
    ciphertextFile = fopen(ciphertext, "wb");
    if (plaintextFile == NULL || publicKeyFile == NULL || ciphertextFile == NULL) {
        perror("Failed to open file");
        exit(EXIT_FAILURE);
    }

    // Read RSA public key (n, e)
    mpz_t n_gmp, e_gmp, c_gmp, chipher_gmp;
    mpz_inits(n_gmp, e_gmp, c_gmp, chipher_gmp, NULL);

    // Assuming the key is stored in hexadecimal in the key file
    gmp_fscanf(publicKeyFile, "%Zx,%Zx", n_gmp, e_gmp);
    fclose(publicKeyFile);

    // Check the size of the modulus (n), as RSA encryption typically works on blocks smaller than n
    size_t modulusSize = (mpz_sizeinbase(n_gmp, 2) + 7) / 8;  // Size of modulus in bytes
    unsigned char buffer[modulusSize];  // Buffer for plaintext data to be encrypted
    unsigned char *encryptedBuffer;     // Buffer for encrypted data

    size_t bytesRead;
    while ((bytesRead = fread(buffer, 1, modulusSize - 1, plaintextFile)) > 0) {
        // Import the block of data as a GMP integer
        mpz_import(c_gmp, bytesRead, 1, 1, 0, 0, buffer);

        // Perform RSA encryption: c^e mod n
        mpz_powm(chipher_gmp, c_gmp, e_gmp, n_gmp);

        // Export the encrypted data into binary and write to the ciphertext file
        size_t count = (mpz_sizeinbase(chipher_gmp, 2) + 7) / 8;
        
        encryptedBuffer = malloc(count);
        mpz_export(encryptedBuffer, &count, 1, 1, 0, 0, chipher_gmp);

        if (fwrite(encryptedBuffer, 1, count, ciphertextFile) != count) {
            perror("Failed to write encrypted data");
            free(encryptedBuffer);
            exit(EXIT_FAILURE);
        }
        free(encryptedBuffer);
    }
   
    // Close files and clear GMP variables
    fclose(plaintextFile);
    fclose(ciphertextFile);
    mpz_clears(n_gmp, e_gmp, c_gmp, chipher_gmp, NULL);
   
}


void decryptRSA(char* plaintext, char* ciphertext, char* privateKey) {
    FILE *plaintextFile, *ciphertextFile, *privateKeyFile;

    // Open files for reading and writing
    plaintextFile = fopen(plaintext, "w");
    ciphertextFile = fopen(ciphertext, "rb");
    privateKeyFile = fopen(privateKey, "r");
    if (plaintextFile == NULL || privateKeyFile == NULL || ciphertextFile == NULL) {
        perror("Failed to open file");
        exit(EXIT_FAILURE);
    }

    // Read RSA private key (n, d)
    mpz_t n_gmp, d_gmp, chipher_gmp, plain_gmp;
    mpz_inits(n_gmp, d_gmp, chipher_gmp, plain_gmp, NULL);

    // Assuming the key is stored in hexadecimal in the key file
    gmp_fscanf(privateKeyFile, "%Zx,%Zx", n_gmp, d_gmp);
    fclose(privateKeyFile);

    // Check the size of the modulus (n), as RSA encryption typically works on blocks smaller than n
    size_t modulusSize = (mpz_sizeinbase(n_gmp, 2) + 7) / 8;  // Size of modulus in bytes
    unsigned char buffer[modulusSize];  // Buffer for plaintext data to be decrypted
    unsigned char *output;
   
    size_t bytesRead;
    // Read and decrypt the ciphertext block by block
    while ((bytesRead = fread(buffer, 1, modulusSize, ciphertextFile))>0) {

    	// Import the ciphertext block as a GMP integer
    	mpz_import(chipher_gmp, bytesRead, 1, 1, 0, 0, buffer);

    	// Perform RSA decryption: c^d mod n
    	mpz_powm(plain_gmp, chipher_gmp, d_gmp, n_gmp);

    	size_t count = (mpz_sizeinbase(plain_gmp, 2) + 7)/ 8;
    	
    	// Export decrypted data back to plaintext
    	//unsigned char output[block_size];
    	output = malloc(count);
    	mpz_export(output, &count, 1, 1, 0, 0, plain_gmp);

    	// Write the decrypted character(s) to the plaintext file
    	if (fwrite(output, 1, count, plaintextFile) != count) {
            perror("Failed to write decrypted data");
            free(output);
            exit(EXIT_FAILURE);
        }
        
        free(output);
    }
    
    // Free allocated memory and clear GMP variables
    fclose(ciphertextFile);
    fclose(plaintextFile);
    mpz_clears(n_gmp, d_gmp, chipher_gmp, plain_gmp, NULL);

}

void key_compare(char *file){

    generateRSAKeyPair(1024);
    generateRSAKeyPair(2048);       
    generateRSAKeyPair(4096);


    FILE * perf_file;
    perf_file = fopen(file,"w");
            
    clock_t start_time, end_time;
    struct rusage usage_before, usage_after;
    double cpu_time_used;
    long enc_mem, dec_mem;

     fprintf(perf_file, "\n-------------- Time Comparison File --------------\n\n");

    /* ---------------------- 1024 ---------------------- */
    // Record the start time
    start_time = clock();

    getrusage(RUSAGE_SELF, &usage_before);
    encryptRSA("plaintext.txt", "enc_1024.txt", "public_1024.key");
    getrusage(RUSAGE_SELF, &usage_after);
    
    // Record the end time
    end_time = clock();
    
    // Calculate CPU time used
    cpu_time_used = ((double)(end_time - start_time)) / CLOCKS_PER_SEC;

    // Calculate memory usage time
    enc_mem = (usage_after.ru_maxrss * 1024) - (usage_before.ru_maxrss * 1024);
    
    // Write the execution time to the output file
    fprintf(perf_file,"Key Length: 1024 bits\n");
    fprintf(perf_file, "Encryption Time: %f s\n", cpu_time_used);

    // ----------------------------------

    // Record the start time
    start_time = clock();

    getrusage(RUSAGE_SELF, &usage_before);
    decryptRSA("dec_1024.txt", "enc_1024.txt", "private_1024.key");
    getrusage(RUSAGE_SELF, &usage_after);

    // Record the end time
    end_time = clock();

    // Calculate the CPU time used
    cpu_time_used = ((double)(end_time - start_time)) / CLOCKS_PER_SEC;

    // Calculate memory usage time
    dec_mem = (usage_after.ru_maxrss * 1024) - (usage_before.ru_maxrss * 1024);
    
    // Write the execution time to the output file
    fprintf(perf_file, "Decryption Time: %f s\n", cpu_time_used);
    fprintf(perf_file, "Peak Memory Usage (Encryption): %ld Bytes\n", enc_mem); 
    fprintf(perf_file, "Peak Memory Usage (Decryption): %ld Bytes\n", dec_mem); 
    fprintf(perf_file, "\n--------------------------------------------------\n\n");



    /* ---------------------- 2048 ---------------------- */
    // Record the start time
    start_time = clock();

    getrusage(RUSAGE_SELF, &usage_before);
    encryptRSA("plaintext.txt", "enc_2048.txt", "public_2048.key");
    getrusage(RUSAGE_SELF, &usage_after);

    // Record the end time
    end_time = clock();

    // Calculate the CPU time used
    cpu_time_used = ((double)(end_time - start_time)) / CLOCKS_PER_SEC;

    // Calculate memory usage time
    enc_mem = (usage_after.ru_maxrss * 1024) - (usage_before.ru_maxrss * 1024);
    
    // Write the execution time to the output file
    fprintf(perf_file,"Key Length: 2048 bits\n");
    fprintf(perf_file, "Encryption Time: %f s\n", cpu_time_used);
    
    // ----------------------------------
    // Record the start time
    start_time = clock();

    getrusage(RUSAGE_SELF, &usage_before);
    decryptRSA("dec_2048.txt", "enc_2048.txt", "private_2048.key");
    getrusage(RUSAGE_SELF, &usage_after);

    // Record the end time
    end_time = clock();

    // Calculate the CPU time used
    cpu_time_used = ((double)(end_time - start_time)) / CLOCKS_PER_SEC;

    // Calculate memory usage time
    dec_mem = (usage_after.ru_maxrss * 1024) - (usage_before.ru_maxrss * 1024);
    
    // Write the execution time to the output file
    fprintf(perf_file, "Decryption Time: %f s\n", cpu_time_used);
    fprintf(perf_file, "Peak Memory Usage (Encryption): %ld Bytes\n", enc_mem); 
    fprintf(perf_file, "Peak Memory Usage (Decryption): %ld Bytes\n", dec_mem);
    fprintf(perf_file, "\n--------------------------------------------------\n\n");



    /* ---------------------- 4096 ---------------------- */
    // Record the start time
    start_time = clock();

    getrusage(RUSAGE_SELF, &usage_before);
    encryptRSA("plaintext.txt", "enc_4096.txt", "public_4096.key");
    getrusage(RUSAGE_SELF, &usage_after);

    // Record the end time
    end_time = clock();

    // Calculate the CPU time used
    cpu_time_used = ((double)(end_time - start_time)) / CLOCKS_PER_SEC;

    // Calculate memory usage time
    enc_mem = (usage_after.ru_maxrss * 1024) - (usage_before.ru_maxrss * 1024);
    
    // Write the execution time to the output file
    fprintf(perf_file,"Key Length: 4096 bits\n");
    fprintf(perf_file, "Encryption Time: %f s\n", cpu_time_used);

    // ----------------------------------
    // Record the start time
    start_time = clock();

    getrusage(RUSAGE_SELF, &usage_before);
    decryptRSA("dec_4096.txt", "enc_4096.txt", "private_4096.key");
    getrusage(RUSAGE_SELF, &usage_after);

    // Record the end time
    end_time = clock();

    // Calculate the CPU time used
    cpu_time_used = ((double)(end_time - start_time)) / CLOCKS_PER_SEC;
    fprintf(perf_file,"%ld before", usage_before.ru_maxrss*1024);
    fprintf(perf_file,"%ld after", usage_after.ru_maxrss*1024);
    // Calculate memory usage time
    dec_mem = (usage_after.ru_maxrss * 1024) - (usage_before.ru_maxrss * 1024);
    
    // Write the execution time to the output file
    fprintf(perf_file, "Decryption Time: %f s\n", cpu_time_used);
    fprintf(perf_file, "Peak Memory Usage (Encryption): %ld Bytes\n", enc_mem); 
    fprintf(perf_file, "Peak Memory Usage (Decryption): %ld Bytes\n", dec_mem);
    // Close the output file
    fclose(perf_file);
}


int main(int argc, char* argv[]){
   
    	char *inputFile, *outputFile, *keyFile, *perf_file;
    	int length;
    	int opt;
    
    	bool caseI = false;
    	bool caseO = false;
    	bool caseK = false;
    	bool caseG = false;
    	bool caseA = false;
    	bool caseD = false;
    	bool caseE = false;
    	bool caseH = false;

	while((opt = getopt(argc, argv, "i:o:k:g:a:deh")) != -1){
		switch(opt){
			case 'i':
				caseI = true;
				inputFile = optarg;
				break;
			case 'o':
				caseO = true;
				outputFile = optarg;
				break;
			case 'k': 
                		caseK = true;
                		keyFile = optarg;
                		break;

            		case 'g': 
                		caseG = true;
                		length = atoi(optarg);      // Special command for int variables
                		break;

            		case 'a':
                		caseA = true;
                		perf_file = optarg;
                		break;

            		case 'd': 
                		caseD = true;
                		break; 

            		case 'e': 
                		caseE = true;
                		break;

            		case 'h': 
                		caseH = true;
                	break;
        		} 
    		}

    		if(caseH)
        		printf("Options:\n"
        		"-i\tpath\tPath to the input file\n"
        		"-o\tpath\tPath to the output filer\n"
        		"-k\tpath\tPath to the key file\n" 
        		"-g\t\tPerform RSA key-pair generation\n"
        		"-d\t\tmakeDecrypt input and store results to output\n"
        		"-e\t\tEncrypt input and store results to output\n"
        		"-a\t\tCompare the performance of RSA encryption and decryption with three different key lengths (1024, 2048, 4096 key lengths) in terms of computational time.\n"
        		"-h\t\tThis help message\n");

    		if(caseE && caseD){
        		printf("Invalid arguments, encryption and decryption must happen on different runs.\n");
        		return -1;
    		}

    		if((caseE||caseD) && (!caseI||!caseO||!caseK)){
        		printf("Invalid arguments, try again.\n");
        		return -1;
    		}

    		if(caseG)
        		generateRSAKeyPair(length);

    		if(caseA)
        		key_compare(perf_file);
        
    		if (caseE)
        		encryptRSA(inputFile, outputFile, keyFile);
        
    		else if (caseD)
        		decryptRSA(outputFile, inputFile, keyFile);
		
    
    	return 0;
}
