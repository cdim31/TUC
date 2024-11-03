# Lab Report: Elliptic Curve Diffie-Hellman (ECDH) Key Exchange and RSA Encryption/Decryption

**Authors:**  
Michalis Lamprakis - 2020030077  
Christos Dimas     - 2021030183

This `README.md` serves as a lab report for the first exercise, explaining the code implementation of two cryptographic algorithms: Elliptic Curve Diffie-Hellman Key Exchange and RSA (Rivest–Shamir–Adleman) encryption/decryption.

---

## Elliptic Curve Diffie-Hellman Key Exchange

The ECDH Key Exchange is implemented using libsodium library. The aim is to create a tool that
enables secure key exchange between two parties (Alice and Bob). Alice and Bob agree to use the
Curve25519 elliptic curve for the ECDH key exchange. The program first generates for both of them Private and Public keys and then calculates the Shared Secret as defined by ECDH.

---

## Command Line Options for ECDH Tool:

- `-o path`:    Path to output file
- `-a number`:  Alice's private key
- `-b number`:  Bob's private key
- `-h`:         Help message

---

## RSA (Rivest–Shamir–Adleman) Algorithm

### Key Generation Process:

`generateRSAKeyPair` function:

**Step 1 & 2**:  
   The function generates two prime numbers, `p` and `q`. With the `-g` argument, takes the desired key length.

**Step 3**:  
   Once valid primes are chosen, the program calculates `n` using the `mpz_mul` function.

**Step 4**:  
   It calculates `λ(n)` using `mpz_sub_ui` and `mpz_mul` functions.

**Step 5**:  
   The `e` value (public exponent) is initialized and calculated according to the equation using functions from the same library.

**Step 6**:  
   The program calculates `d` (private exponent) using the `mpz_invert` function.

**Step 7 & Step 8**:  
   Two key files are generated:
   - `public.key` (containing `n` and `e`)
   - `private.key` (containing `n` and `d`)

---

### Encryption Process:

- The input file for encryption will be a plaintext file.
- The output will be a binary file that contains long integer values generated during the encryption process, using the private key. The binary format helps store long variables without truncation.

---

### Decryption Process:

- The input file for decryption will be a binary file.  
- Using the public key, the program will generate a decrypted plaintext file, saved with a user-specified filename.

---

### Performance Analysis

1. The program generates new public and private keys for three different key lengths (1024, 2048, 4096).
2. Using the `clock` function (from the <sys/time.h> library) and the `getrusage.ru_maxrss`(from <sys/resource.h>) one, calculates the time taken and the memory usage for each Encryption/Decryption.
3. The result of the performance analysis is stored in a `.txt` file (specified by the user).

---

## Command Line Options for RSA Tool:

- `-i path`:    Path to input file
- `-o path`:    Path to output file
- `-k path`:    Path to key file
- `-g length`:  Perform RSA key-pair generation given a key length "length"
- `-d`:         Decrypt input and store results to output
- `-e`:         Encrypt input and store results to output
- `-a`:         Performance Analysis
- `-h`:         Help message

---

### Conclusion

This lab report details the implementation of two cryptographic algorithms: Elliptic Curve Diffie-Hellman and RSA. It also explains the key generation, encryption, decryption processes as well as time and memory comparison between different key lengths in RSA encryption.
