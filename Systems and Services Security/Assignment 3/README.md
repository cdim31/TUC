# Lab Report: Malware Detection

**Authors:**  
Michalis Lamprakis - 2020030077  
Christos Dimas     - 2021030183

This `README.md` serves as a lab report for the 3rd exercise, explaining the code implementation of Malware Detection tool.

To run the scripts you need to create a python enviroment and install watchdog

## Main Description

This is a Malware Detection tool in Python with signature-based scanning. It is contained of 3 Tasks. **Signature Database & Detection**, **Search & Quarantine** and **Real-Time Monitoring & Anomaly Detection**.


## Scripts & Explanations

- **taskA.py**: Creates the Database with both Malware and non signatures. To do this, first we create 50 random .txt files with their MD5 and
SHA256 Hashes and stores them to the current working directory. The half of them are Malware named: `Malware_0` to `Malware_24` and the others are non named: `Non_Malware_0` to `Non_Malware_24`. Both Hashes are stored to the database, with the first 25 marked as Malware and the other 25 marked as Non-Malware. So we have a created 50 random files and a database ` malware_signatures.txt.` with 50 known Hashes. To confirm that everything is fine we calculate again the Hashes for each file we created and compare them with the signature database. The result is printed and as expected the categorization is 25 Malware and 25 Non-Malware test Files.


    For the Task A3 we calculated the hashes 
    (sha1, SHA512, SHA256) of the given pdf files 
    and perform pairwise comparisons between all hashes.
    Doing all the comparisons, all hashes are different.
    This could affect malware detection in both positive and negative
    ways. Fisrt unique hashes ensure that each 
    file can be uniquely identified, which minimizes false detection.
    On the other hand, if two malware samples have slight variations but are functionally the same, they will generate different hashes. This means the system might fail to detect related or mutated malware if it only relies on exact hash matching.

    **Implementation Details**

    Script additionally creates `test_directory` with 3 subdirectories, where the files are also stored after their creation to be used in `taskB`. Furthermore, to complete task A3, the path to the pdf folder might need to be adjusted (current folder: `/working_directory/sample_pdfs`)

- **taskB.py**: We use the directory named `test_directory` with its subdirectories, created in Task A, that contains the test files . The functionality of the script is that recursively scans the given directory, write detection logs and provides a `report.log` file. Also it contains a Quarantine system that isolates the threats into `/working_directory/quarantine`, prints its threat level with a short description and also provides a `quarantine.log`, for testing purposes. We tested the script with the 50 files we created and the result is as expected 25 Malware and 25 Non Malware.

    **Implementation Details**

    The test_directory is setted by default as `/working_directory/test_directory`.

- **taskC.py**: A Monitoring tool that finds and checks a directory 
real-time for any file creation, modification or deletion. 
It inlcudes the `taskA.py` and checks for Malware-Infected 
files and prints in the file `real_time.log`. It also 
Quarantines any new generated or modified infected files 
(like Task B).

    **Implementation Details**

    Script scans from root(`/`) directory, in order to be able to find the `directory_name` given by the user, wherever it is.

    To test the script, we set by default:
    - Directory : `/working_directory/test_directory`
    - Signature Database : `/working_directory/malware_signatures.txt`
    - Output File : `/working_directory/quarantine.log`

- **malware_detection_tool.py**: The main Malware Detection tool that combine the functionalities of the three Tasks.


## Instructions

Get inside the project's directory:
```bash
cd 2020030077_2021030183_assign3
```

Activate python's virtual environment:
```bash
source toolenv/bin/activate
```

The `malware_detection_tool.py` accepts the following command-line arguments:

- `-d <directory>`: Specifies the directory to scan.

- `-s <signature file>`: Path to the malware signature database file. 

- `-o <output file>`: File to save a report of infected files.

- `-r` (optional): Enables real-time monitoring mode.

## Example Usage

### Basic Scan
To perform a one-time scan of a directory:
```bash
python malware_detection_tool.py -d directory_name -s /path/to/malware_signatures.txt -o /path/to/output_report.txt
```
### Real-Time Monitoring
To enable real-time monitoring of a directory:
```bash
python malware_detection_tool.py -d directory_name -s /path/to/malware_signatures.txt -o /path/to/output_report.txt -r
```
### Run tasks individually


```bash
python taskA.py
python taskB.py
python tasKC.py
```
