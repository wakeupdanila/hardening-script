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

# Configure password policy
pattern="PASS_MIN_DAYS\t0"
file="/etc/login.defs"
if grep -q "$pattern" "$file"; then
    perform_action "Configure password policy" "sed -i 's/PASS_MIN_DAYS\t0/PASS_MIN_DAYS\t7/' $file"
else
    warn "Pattern $pattern not found in $file. Skipping sed command."
fi

# Configure SELinux
pattern="SELINUX=disabled"
file="/etc/selinux/config"
if grep -q "$pattern" "$file"; then
    perform_action "Configure SELinux" "sed -i 's/SELINUX=disabled/SELINUX=enforcing/' $file"
else
    warn "Pattern $pattern not found in $file. Skipping sed command."
fi

# Configure firewall (firewall-cmd)
perform_action "Configure firewall" "firewall-cmd --permanent --add-service=http"
perform_action "Reload firewall" "firewall-cmd --reload"

# Configure SSH
perform_action "Check if openssh-server is installed" "yum list installed openssh-server"
backup_files /etc/ssh/sshd_config

# Disable root login via SSH
pattern="PermitRootLogin yes"
file="/etc/ssh/sshd_config"
if grep -q "$pattern" "$file"; then
    perform_action "Disable root login via SSH" "sed -i 's/PermitRootLogin yes/PermitRootLogin no/' $file"
else
    warn "Pattern $pattern not found in $file. Skipping sed command."
fi

# Configure SSH ciphers
perform_action "Configure SSH ciphers" "sed -i '$a Ciphers aes256-gcm@openssh.com,aes128-gcm@openssh.com,chacha20-poly1305@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr' /etc/ssh/sshd_config"

# Configure auditd
perform_action "Configure auditd" "echo '-w /etc/passwd -p wa -k identity' >> /etc/audit/rules.d/audit.rules"

# Configure Apache HTTP server
perform_action "Install Apache" "yum install -y httpd"
perform_action "Start Apache" "systemctl start httpd"
perform_action "Enable Apache at boot" "systemctl enable httpd"

# Disable Empty Passwords
pattern="PermitEmptyPasswords yes"
file="/etc/ssh/sshd_config"
if grep -q "$pattern" "$file"; then
    perform_action "Disable Empty Passwords" "sed -i 's/PermitEmptyPasswords yes/PermitEmptyPasswords no/' $file"
else
    warn "Pattern $pattern not found in $file. Skipping sed command."
fi

# Disable X11 Forwarding
pattern="X11Forwarding yes"
file="/etc/ssh/sshd_config"
if grep -q "$pattern" "$file"; then
    perform_action "Disable X11 Forwarding" "sed -i 's/X11Forwarding yes/X11Forwarding no/' $file"
else
    warn "Pattern $pattern not found in $file. Skipping sed command."
fi

# Enable Automatic Security Updates
perform_action "Enable Automatic Security Updates" "yum install -y yum-cron"
perform_action "Configure Automatic Security Updates" "sed -i 's/apply_updates = no/apply_updates = yes/' /etc/yum/yum-cron.conf"
perform_action "Start Automatic Security Updates" "systemctl start yum-cron"
perform_action "Enable Automatic Security Updates at boot" "systemctl enable yum-cron"

# Install and Configure Fail2Ban
perform_action "Install Fail2Ban" "yum install -y fail2ban"
perform_action "Start Fail2Ban" "systemctl start fail2ban"
perform_action "Enable Fail2Ban at boot" "systemctl enable fail2ban"

# Install and Configure AIDE
perform_action "Install AIDE" "yum install -y aide"
perform_action "Initialize AIDE" "aide --init"
perform_action "Configure AIDE" "mv /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz"