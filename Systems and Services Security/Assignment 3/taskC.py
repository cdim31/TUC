#!/usr/bin/env python3

import os
import time
import argparse
from datetime import datetime
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler
import taskA
import taskB


class MalwareEventHandler(FileSystemEventHandler):
    """
    A custom event handler class that monitors directory changes and performs malware detection
    on newly created, modified, and deleted files.
    """
    def __init__(self, signatures, real_time_log_file, quarantine_log_file):
        """
        Initializes the event handler with necessary parameters for malware detection and logging.
        """
        self.signatures = signatures
        self.real_time_log_file = real_time_log_file
        self.quarantine_log_file = quarantine_log_file

    def on_created(self, event):
        """
        Called when a file is created in the monitored directory.
        """
        if not event.is_directory:
            self.detect_and_log(event.src_path, "Creation")

    def on_modified(self, event):
        """
        Called when a file is modified in the monitored directory.
        """
        if not event.is_directory:
            self.detect_and_log(event.src_path, "Modification")

    def on_deleted(self, event):
        """
        Called when a file is deleted from the monitored directory.
        Logs the deletion but does not perform malware detection.
        """
        if not event.is_directory:
            self.real_time_log(event.src_path, "Deletion")

    def detect_and_log(self, file_path, action):
        """
        Detects malware in a file and logs the actions taken.
        """
        if not os.path.exists(file_path):
            return  # Skip, as file might have been moved or already handled

        try:
            md5, sha256 = taskB.compute_hashes(file_path)
        except PermissionError:
            print(f"Permission denied: {file_path}")
            return
	
        is_malware, malware_type, threat_level = taskA.detect_malware(self.signatures, md5, sha256)

        self.real_time_log(file_path, action)
        if is_malware:
            file_name = os.path.basename(file_path)
            quarantined_path = taskB.quarantine_file(file_name, file_path, malware_type, threat_level, self.quarantine_log_file)

    def real_time_log(self, file_path, action):
        """
        Logs file actions to a designated log file.
        """
        with open(self.real_time_log_file, "a") as log:
            log.write(f"{datetime.now()} - Action Date\n")
            log.write(f"Original Path: {file_path}\n")
            log.write(f"Action Performed: {action}\n")
            log.write("-" * 60 + "\n")


def real_time(args):
    """
    Main function to initialize and start the watchdog observer to monitor directory changes.
    """
    signatures = taskA.load_signature_database(args.signature)
    print("Searching for the directory...")
    file_path = None
    for root, dirs, files in os.walk("/"):
        if args.directory in dirs:
            file_path = os.path.join(root, args.directory)

    if not file_path:
        print("Directory not found.")
        return

    event_handler = MalwareEventHandler(signatures, "real_time.log", args.output)
    observer = Observer()
    observer.schedule(event_handler, path=file_path, recursive=True)
    observer.start()

    print(f"Monitoring directory {args.directory} for malware in real-time...")
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        print("Monitoring stopped by user.")
        observer.stop()
    observer.join()


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Task C")
    parser.add_argument("-d", "--directory", default="test_directory", help="Directory to monitor for changes.")
    parser.add_argument("-s", "--signature", default="malware_signatures.txt", help="File containing malware signatures.")
    parser.add_argument("-o", "--output", default="quarantine.log", help="Log file for quarantined files.")
    args = parser.parse_args()
    real_time(args)
