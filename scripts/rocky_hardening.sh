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
perform_action "Check password quality" "yum install -y libpwquality" "libpwquality"

# Configure password policy
perform_action "Configure password policy" "echo 'PASS_MIN_DAYS\t7' >> /etc/login.defs"

# Configure SELinux
perform_action "Configure SELinux" "echo 'SELINUX=enforcing' >> /etc/selinux/config"

# Configure firewall (firewall-cmd)
perform_action "Configure firewall" "firewall-cmd --permanent --add-service=http"
perform_action "Reload firewall" "firewall-cmd --reload"

# Configure SSH
perform_action "Check if openssh-server is installed" "yum list installed openssh-server" "openssh-server"
backup_files /etc/ssh/sshd_config

# Disable root login via SSH
perform_action "Disable root login via SSH" "echo 'PermitRootLogin no' >> /etc/ssh/sshd_config"

# Configure SSH ciphers
perform_action "Configure SSH ciphers" "echo 'Ciphers aes256-gcm@openssh.com,aes128-gcm@openssh.com,chacha20-poly1305@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr' >> /etc/ssh/sshd_config"

# Configure auditd
perform_action "Configure auditd" "echo '-w /etc/passwd -p wa -k identity' >> /etc/audit/rules.d/audit.rules"

# Configure Apache HTTP server
perform_action "Install Apache" "yum install -y httpd" "httpd"
perform_action "Start Apache" "systemctl start httpd"
perform_action "Enable Apache at boot" "systemctl enable httpd"

# Disable Empty Passwords
perform_action "Disable Empty Passwords" "echo 'PermitEmptyPasswords no' >> /etc/ssh/sshd_config"

# Disable X11 Forwarding
perform_action "Disable X11 Forwarding" "echo 'X11Forwarding no' >> /etc/ssh/sshd_config"

# Enable Automatic Security Updates
perform_action "Install dnf-automatic" "yum install -y dnf-automatic" "dnf-automatic"
perform_action "Configure dnf-automatic to automatically install updates" "echo 'upgrade_type = default' >> /etc/dnf/automatic.conf"
perform_action "Enable dnf-automatic timer" "systemctl enable --now dnf-automatic.timer"

# Install and Configure Fail2Ban
perform_action "Install Fail2Ban" "yum install -y fail2ban" "fail2ban"
perform_action "Start Fail2Ban" "systemctl start fail2ban"
perform_action "Enable Fail2Ban at boot" "systemctl enable fail2ban"

# Install and Configure AIDE
perform_action "Install AIDE" "yum install -y aide" "aide"
perform_action "Initialize AIDE" "aide --init"
perform_action "Configure AIDE" "mv /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz"

info "System hardening completed successfully"