#!/bin/bash

source utils.sh

# Check that the script is being run on Rocky Linux 9
if grep -q "Rocky Linux 9" /etc/os-release; then
    info "Running on Rocky Linux 9"
else
    error "This script is intended for Rocky Linux 9"
    exit 1
fi

# Update the system
perform_action "Check for security updates" "yum update -qy --security"

# Configure umask
perform_action "Configure umask" "echo 'umask 027' >> /etc/profile"

# Check password quality and password policy
perform_action "Check password quality" "yum install -y libpwquality"
perform_action "Configure password policy" "sed -i 's/PASS_MIN_DAYS\t0/PASS_MIN_DAYS\t7/' /etc/login.defs"

# Configure SELinux
perform_action "Configure SELinux" "sed -i 's/SELINUX=disabled/SELINUX=enforcing/' /etc/selinux/config"

# Configure firewall (firewall-cmd)
perform_action "Configure firewall" "firewall-cmd --permanent --add-service=http"
perform_action "Reload firewall" "firewall-cmd --reload"

# Configure SSH
perform_action "Check if openssh-server is installed" "yum list installed openssh-server"
backup_files /etc/ssh/sshd_config
perform_action "Disable root login via SSH" "sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config"
perform_action "Configure SSH ciphers" "sed -i '$a Ciphers aes256-gcm@openssh.com,aes128-gcm@openssh.com,chacha20-poly1305@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr' /etc/ssh/sshd_config"

# Configure auditd
perform_action "Configure auditd" "echo '-w /etc/passwd -p wa -k identity' >> /etc/audit/rules.d/audit.rules"

# Configure Apache HTTP server
perform_action "Install Apache" "yum install -y httpd"
perform_action "Start Apache" "systemctl start httpd"
perform_action "Enable Apache at boot" "systemctl enable httpd"