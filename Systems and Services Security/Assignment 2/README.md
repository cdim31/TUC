# Lab Report: Access Control Logging

**Authors:**  
Michalis Lamprakis - 2020030077  
Christos Dimas     - 2021030183

This `README.md` serves as a lab report for the first exercise, explaining the code implementation of Access Control Logging & Monitoring tool.

## Main Description

This is an access control logging system developed in C, designed to track all file accesses and modifications triggered by a user's program. Each file operation generates an entry in a log file, which facilitates in-depth analysis by a privileged process. The log file, created in the same directory, captures key details for enhanced security monitoring, providing a concise yet effective solution for comprehensive file activity tracking.


## Modules

- **logger.c**: Creates log files and overrides standard fopen and fwrite functions. This module collects data such as the user ID, date/time of the action, user permissions, and generates an SHA256 hash of the file content after each fwrite call, logging all information into file_logging.log.
- **acmonitor.c**: Implements the monitoring tools that utilize the logged data to identify potential security breaches, including detecting malicious users—those attempting to access a file without the necessary permissions.
- **test_aclog.c**: Contains tests to verify the functionalities of the logging and monitoring system, simulating various file operations to create scenarios for the tools to capture and analyze.

## Testing Logger

### Test 1: Basic File Operations
- **Objective**: Open and write to file_0 to file_9.
- **Expected Logs**: 20 lines (2 per file).
  -Access type flag 0 for creating and the empty file hash
  -Access type flag 2 for writing and the resulting hash

### Test 2: Permission Changes
- **Objective**: Create, modify, and change permissions of files, then attempt to open them 4 times each.
- **Expected Logs**: 12 lines.
  - 2 lines creating and the empty file hash.
  - 2 lines for writting.
  - 8 lines deny access flag active (4 each) .

### Test 3: Read Operation
- **Objective**: Open file_4 for reading.
- **Expected Logs**: 1 line matching the hash from Test 1.

### Test 4: Append Operation
- **Objective**: Append to file_2.
- **Expected Logs**: 2 lines.
  - 1 line with type of 1 and the same hash as in TEST one since the contents did not change.
  - 1 line with access type of 2 and results in a different hash.

## Testing the Monitor

### Test 1: Malicious Users Detection
- **Objective**: Simulate users by creating different logs. Create 100 logs. Simulate trying to acces multiple file multiple times.
- **Expected Output**: 5 malicius users.

### Test 2: File Modification Tracking
- **Objective**: Simulate users by creating different logs. Create 100 logs .Set filepath = file_8 
- **Expected Output (`-i file_8`)**: 5 malicius users. 11 lines where file_8 was modified
  -1 from user 1000 which was in TEST 1 from the logger tests.
  -10 more lines for each user.

## Makefile Commands

- `make all`: Builds the project.
- `make run`: Runs the tester with the shared library preloaded.
- `make clean`: Cleans object files, removes test files, executable files, and deletes the log file.

## Running the System

- **Build the system:** `make all`
- **Update LogFile:** `make run`
- **Identify & Print Information for Malicious Users:** `./acmonitor -m`
- **Identify & Print Information for Users Accessing a Specified File:** `./acmonitor -i [path to filename]`
- **Clear LogFile & Erase Executable Files:** `make clean`
