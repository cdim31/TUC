#!/usr/bin/env python3

import os
import hashlib
import time
import shutil
from datetime import datetime
import taskA  # Importing the taskA module, which contains helper functions

# Function to compute MD5 and SHA256 hashes for a file
def compute_hashes(file_path):
    """
    Compute MD5 and SHA256 hashes for the specified file.

    :param file_path: Path to the file to hash
    :return: Tuple of MD5 and SHA256 hash strings
    """
    md5 = hashlib.md5()
    sha256 = hashlib.sha256()

    try:
        with open(file_path, 'rb') as f:
            while chunk := f.read(8192):  # Read file in chunks to handle large files
                md5.update(chunk)
                sha256.update(chunk)
    except IOError as e:
        print(f"Error reading file '{file_path}': {e}")
        return None, None  # Return None if there’s an error

    return md5.hexdigest(), sha256.hexdigest()


# Function to detect and quarantine suspicious files
def quarantine_file(file_name, file_path, malware_type, severity_level, output_file):
    """
    Move a suspicious file to a quarantine directory and log the details.

    :param file_name: Name of the file
    :param file_path: Original path of the file
    :param malware_type: Type of malware detected
    :param severity_level: Threat level of the malware
    :param output_file: Path to the log file for quarantine details
    :return: Path to the quarantined file
    """
    quarantine_dir = os.path.join(os.getcwd(), "quarantine")
    
    # Ensure the quarantine directory exists
    os.makedirs(quarantine_dir, exist_ok=True)
    
    # Construct the path for the quarantined file
    quarantined_path = os.path.join(quarantine_dir, file_name)

    try:
        shutil.move(file_path, quarantined_path)  # Move the file to quarantine
        description = f"{malware_type} detected with threat level {severity_level}."

        # Log quarantine details
        with open(output_file, "a") as log_file:
            log_file.write(f"{datetime.now()} - {file_name} quarantined.\n")
            log_file.write(f"Original Path: {file_path}\n")
            log_file.write(f"Quarantine Path: {quarantined_path}\n")
            log_file.write(f"Threat Level: {severity_level}\n")
            log_file.write(f"Description: {description}\n")
            log_file.write("-" * 60 + "\n")  

        print(f"Malware detected in {file_path} and quarantined at {quarantined_path}")
    except (IOError, shutil.Error) as e:
        print(f"Error quarantining file '{file_path}': {e}")
        return None  # Return None if there’s an error during quarantine

    return quarantined_path


# Function to scan a directory recursively and log results
def scan_directory(directory, signature_file, log_file, output_file):
    """
    Scan a directory recursively for malware, logging results and quarantining suspicious files.

    :param directory: Path to the directory to scan
    :param signature_file: Path to the malware signature database file
    :param log_file: Path to the file to log scan results
    :param output_file: Path to the file to log quarantined files
    """
    # Load malware signatures
    try:
        malware_signatures = taskA.load_signature_database(signature_file)
    except Exception as e:
        print(f"Error loading signature database: {e}")
        return

    log_entries = []  # List to store log entries
    print("Searching for the directory...")
    file_path = None
    for root, dirs, files in os.walk("/"):
        if directory in dirs:
            file_path = os.path.join(root, directory)

    if not file_path:
        print("Directory not found.")
        return

    # Walk through the directory recursively
    for root, dirs, files in os.walk(file_path):
        for file_name in files:
            file_path = os.path.join(root, file_name)
            try:
                # Get file metadata
                file_size = os.path.getsize(file_path)
                file_timestamp = time.ctime(os.path.getmtime(file_path))
                
                # Compute hashes for the file
                md5, sha256 = compute_hashes(file_path)
                if md5 is None or sha256 is None:  # Skip if hashes couldn’t be computed
                    continue

                # Check if the file matches any malware signature
                is_malware, malware, threat_level = taskA.detect_malware(malware_signatures, md5, sha256)

                # If a match is found, quarantine the file
                if is_malware:
                    quarantined_path = quarantine_file(file_name, file_path, malware, threat_level, output_file)
                    matched_signature = "Yes"
                else:
                    matched_signature = "No"

                # Add entry to the log_entries list
                log_entries.append({
                    "file_path": file_path,
                    "md5": md5,
                    "sha256": sha256,
                    "matched_signature": matched_signature,
                    "file_size": file_size,
                    "timestamp": file_timestamp
                })
            except PermissionError as e:
                print(f"Permission denied for file '{file_path}': {e}")
            except IOError as e:
                print(f"Error processing file '{file_path}': {e}")

    # Sort log entries by whether a signature was matched
    log_entries = sorted(log_entries, key=lambda x: x["matched_signature"])

    # Write sorted entries to the log file
    try:
        with open(log_file, 'a') as log:
            log.write("File Scan Report\n")
            log.write(f"Scan Timestamp: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
            log.write("File Path | MD5 | SHA256 | Matched Signature | File Size (bytes) | Timestamp\n")
            log.write("-" * 100 + "\n")
            
            for entry in log_entries:
                log.write(f"{entry['file_path']} | {entry['md5']} | {entry['sha256']} | {entry['matched_signature']} | "
                          f"{entry['file_size']} | {entry['timestamp']}\n")
        print(f"Scan completed. Results saved in {log_file}.")
    except IOError as e:
        print(f"Error writing to log file '{log_file}': {e}")


# Run the scan
if __name__ == "__main__":
    # Define directories and files for scanning, signatures, and logs
    directory_to_scan = 'test_directory'  # Directory to scan for malware
    signature_file_path = 'malware_signatures.txt'  # Malware signature database
    log_file_path = 'report.log'  # Log file for scan results
    quarantine_log_file_path = 'quarantine.log'  # Log file for quarantine details

    # Execute the scan
    scan_directory(directory_to_scan, signature_file_path, log_file_path, quarantine_log_file_path)
