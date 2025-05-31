# abhi_bash_assignment
This repository contains Bash scripts designed to automate administrative tasks within an Ubuntu container running in Docker. The scripts focus on user management, environment setup, and directory backup.
# Bash Automation Assignment – abhi_bash_assignment

##  Folder Structure

```bash
abhi_bash_assignment/
├── task1/
│   ├── mymanagers.sh       # Script to create users from CSV
│   ├── users.csv           # Input CSV file for user creation
│   └── screenshots/        # Screenshots for Task 1 execution
│

├── task2/
```
│   ├── backup.sh           # Script for prompting backup folder
│   └── screenshots/        # Task 2 execution screenshots
│\\
├── README.md               # Project description and instructions
└── BashSelfAssessment.txt  # Self-reflection on the process and learning

## Task 1 – Creation of User from CSV

### ???? Script: `mymanagers.sh`
- Reads `users.csv` file
- Extracts username from email
- Creates user with password generated from birth month and year
- Adds user to groups
- Creates group folder with appropriate permissions
- Creates symbolic link to shared folder in home of user

###  How to run:
```bash
cd task1
sudo bash mymanagers.sh
```

`users.csv` should be in the same directory.

---

##  Task 2 – Backup Script

###  Script: `backup.sh`
- Asks user for:
  - Directory to be backed up
  - Backup destination
- Output is a `.tar.gz` file with timestamp

###  Running it:
```bash
cd task2
bash backup.sh
```

You will be prompted to enter. Example:
```
Enter the directory to backup: ./task1
Enter backup destination directory: /home/abhishek/backups
```

---

##  Notes:
- Execution screenshots are all stored in the respective `screenshots/` directories in `task1/` and `task2/`.

