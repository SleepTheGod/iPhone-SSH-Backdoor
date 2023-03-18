# iPhone SSH Backdoor
This is a shell script that creates an SSH backdoor on an iPhone. The script creates a new user on the iPhone, creates a folder in the user's home directory, copies the SSH binary to that folder, changes the binary's permissions, creates a launch daemon to run the binary, creates an SSH key, disables password authentication, and restarts the SSH daemon.

Usage
Connect your iPhone to your computer via USB.
Open a terminal window and navigate to the directory where the script is saved.
Execute the script by typing ./ssh-backdoor.sh and pressing Enter.
Disclaimer
This script is for educational purposes only. Do not use it to gain unauthorized access to someone else's device. The author of this script is not responsible for any misuse or damage caused by its use.
