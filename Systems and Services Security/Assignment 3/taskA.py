#!/usr/bin/env python3

import os
import hashlib
import random
from datetime import datetime, timedelta

# Define possible malware types and severity levels
malware_types = ['Worm', 'Ransomware', 'Virus', 'Spyware']
severity_levels = ['Low', 'Medium', 'High', 'Critical']

# Function to generate random data using os.urandom
def generate_random_data(size):
    """
    Generate random data of a specified size and convert it to a hex string.

    :param size: Number of bytes to generate
    :return: Hexadecimal representation of the random data
    """
    return os.urandom(size).hex()

# Function to compute MD5 and SHA256 hashes
def compute_hashes(data):
    """
    Compute MD5 and SHA256 hashes for the provided data.

    :param data: Input data as a string
    :return: Tuple of MD5 and SHA256 hash strings
    """
    md5_hash = hashlib.md5(data.encode()).hexdigest()
    sha256_hash = hashlib.sha256(data.encode()).hexdigest()
    return md5_hash, sha256_hash

# Generate a random date within the last year
def generate_random_date():
    """
    Generate a random date within the past year.

    :return: Date string in the format 'YYYY-MM-DD'
    """
    start_date = datetime.now() - timedelta(days=365)
    random_date = start_date + timedelta(days=random.randint(0, 365))
    return random_date.strftime("%Y-%m-%d")

# Function to load malware signatures from the signature database file
def load_signature_database(filename):
    """
    Load malware signatures from a file into a list of tuples.

    :param filename: Path to the signature database file
    :return: List of tuples containing malware signature information
    """
    signatures = []
    try:
        with open(filename, 'r') as file:
            for line in file:
                if line.startswith("#") or line.strip() == "":  # Skip comments and empty lines
                    continue
                parts = line.strip().split(" | ")
                if len(parts) >= 5:
                    md5, sha256, malware_type, infection_date, severity_level = parts
                    signatures.append((md5, sha256, malware_type, severity_level))
    except FileNotFoundError:
        print(f"Error: Signature file '{filename}' not found.")
    except Exception as e:
        print(f"Error loading signature database: {e}")
    return signatures

# Function to check if a file matches any known malware signature
def detect_malware(malware_signatures, sig_md5, sig_sha256):
    """
    Check if a file's hash matches any known malware signatures.

    :param malware_signatures: List of known malware signatures
    :param sig_md5: MD5 hash of the file
    :param sig_sha256: SHA256 hash of the file
    :return: Tuple (is_malware, malware_type, threat_level)
    """
    for md5, sha256, malware_type, severity_level in malware_signatures:
        if md5 == sig_md5 and sha256 == sig_sha256 and malware_type != 'Non-Malware' and severity_level != 'None':
            return True, malware_type, severity_level
    return False, "", ""

# Function to create directories and files for testing
def create_files(main_directory, num_subdirectories=3):
    """
    Create test files and subdirectories to simulate a malware test environment.

    :param main_directory: Path to the main directory
    :param num_subdirectories: Number of subdirectories to create
    :return: List of created file names
    """
    os.makedirs(main_directory, exist_ok=True)
    subdirectories = [os.path.join(main_directory, f"subdir_{i}") for i in range(1, num_subdirectories + 1)]
    for subdir in subdirectories:
        os.makedirs(subdir, exist_ok=True)

    file_names = []
    try:
        # Open the signature database file in the working directory
        with open("malware_signatures.txt", "w") as test_file:
            test_file.write("MD5 Hash | SHA256 Hash | Malware Type | Infection Date | Severity Level\n")
            test_file.write("-" * 85 + "\n")

            # Create malware and non malware files and randomly distribute them across subdirectories
            for i in range(50):
                is_malware = i < 25 # First 25 files are malware
                file_name = f"{'Malware_' + str(i) + '.txt' if is_malware else 'Non_Malware_' + str(i-25) + '.txt'}"
                subdir = random.choice(subdirectories)  # Choose a random subdirectory
                file_path = os.path.join(subdir, file_name)
                working_file_path = os.path.join(os.getcwd(), file_name)  # Path in the working directory

                with open(file_path, "w") as file, open(working_file_path, "w") as working_file:
                    file_names.append(file_name)
                    
                    # Generate random data and compute hashes
                    data = generate_random_data(random.randint(10, 30))  # Random size between 10 and 30 bytes
                    file.write(data)  # Write to the subdirectory file
                    working_file.write(data)  # Write to the working directory file
                    
                    md5, sha256 = compute_hashes(data)
                    
                    # Assign metadata based on malware status
                    malware_type = random.choice(malware_types) if is_malware else 'Non-Malware'
                    infection_date = generate_random_date() if is_malware else 'None'
                    severity_level = random.choice(severity_levels) if is_malware else 'None'
                    
                    # Write to the signature file
                    test_file.write(f"{md5} | {sha256} | {malware_type} | {infection_date} | {severity_level}\n")
    except IOError as e:
        print(f"Error writing test files: {e}")

    return file_names

# Function to compute SHA1, SHA512, and SHA256 hashes for a file
def compute_hashes_pdf(file_path):
    """
    Compute SHA1, SHA512, and SHA256 hashes for a given file.

    :param file_path: Path to the file
    :return: Tuple of SHA1, SHA512, and SHA256 hash strings
    """
    sha1 = hashlib.sha1()
    sha512 = hashlib.sha512()
    sha256 = hashlib.sha256()

    try:
        with open(file_path, 'rb') as f:
            while chunk := f.read(8192):
                sha1.update(chunk)
                sha512.update(chunk)
                sha256.update(chunk)
    except IOError as e:
        print(f"Error reading file '{file_path}': {e}")
        return None, None, None

    return sha1.hexdigest(), sha512.hexdigest(), sha256.hexdigest()

# Function to process all PDF files in a directory and compute their hashes
def process_pdf_files(directory):
    """
    Process all PDF files in a directory to compute their hashes.

    :param directory: Path to the directory
    :return: List of hash dictionaries for each PDF file
    """
    hash_results = []
    try:
        for file_name in os.listdir(directory):
            if file_name.endswith(".pdf"):
                file_path = os.path.join(directory, file_name)
                sha1, sha512, sha256 = compute_hashes_pdf(file_path)
                if sha1 and sha512 and sha256:
                    hash_results.append({
                        'file_name': file_name,
                        'sha1': sha1,
                        'sha512': sha512,
                        'sha256': sha256
                    })
    except Exception as e:
        print(f"Error processing PDF files: {e}")

    return hash_results

# Function to compare PDF hashes and report matches
def compare_hashes_pdf(hash_results):
    """
    Compare hashes of PDF files and report identical matches.

    :param hash_results: List of hash dictionaries for each file
    :return: List of findings with identical hashes
    """
    findings = []
    n = len(hash_results)

    for i in range(n):
        for j in range(i + 1, n):
            file1, file2 = hash_results[i], hash_results[j]

            if file1['sha1'] == file2['sha1']:
                findings.append(f"{file1['file_name']} and {file2['file_name']} have the same SHA1 hash.")
            if file1['sha512'] == file2['sha512']:
                findings.append(f"{file1['file_name']} and {file2['file_name']} have the same SHA512 hash.")
            if file1['sha256'] == file2['sha256']:
                findings.append(f"{file1['file_name']} and {file2['file_name']} have the same SHA256 hash.")

    return findings

# Function to execute task3
def pdf_comparison(directory):
    hash_results = process_pdf_files(directory)
   
    print("Hashes for each PDF file:")
    for result in hash_results:
        print(f"{result['file_name']}: SHA1={result['sha1']}, SHA512={result['sha512']}, SHA256={result['sha256']}")

    findings = compare_hashes_pdf(hash_results)
    
    print("\nPairwise Comparison Findings:")
    if findings:
        for finding in findings:
            print(finding)
    else:
        print("No identical hashes found between files.")
        
# Main function to execute PDF comparison and malware detection
def main():
    directory = "test_directory"
    signature_file = "malware_signatures.txt"
    path_to_pdfs = "sample_pdfs"

    # Create test files and load malware signatures
    test_files = create_files(directory, num_subdirectories=3)
    malware_signatures = load_signature_database(signature_file)

    # Detect malware in each test file
    for test_file in test_files:
        try:
            with open(test_file, "r") as file:
                data = file.read()
                md5, sha256 = compute_hashes(data)
                is_malware, malware, threat_level = detect_malware(malware_signatures, md5, sha256)
                status = "Malware" if is_malware else "Non-Malware"
                print(f"File name: {test_file}, Status: {status}, Type: {malware}, Severity: {threat_level}")
        except Exception as e:
            print(f"Error processing file '{test_file}': {e}")

    # PDF comparison task
    pdf_comparison(path_to_pdfs)

if __name__ == "__main__":
    main()
