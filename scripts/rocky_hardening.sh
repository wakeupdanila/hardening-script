#!/bin/bash

source utils.sh

# Function to perform an action and log it with an info message
perform_action() {
    local action_description="$1"
    local action_command="$2"
    
    info "Performing: ${action_description}..."
    ${action_command}
    
    exit_on_fail "Failed to ${action_description}"
    
    info "${action_description} completed successfully"
}

# Backup files function
backup_files() {
    local src="$1"
    local dest="./hardening_backup/$(date +%Y%m%d_%H%M%S)"
    
    info "Backing up ${src} to ${dest}..."
    cp -a "${src}" "${dest}"
    exit_on_fail "Failed to create backup of ${src}"
    
    info "Backup created successfully at ${dest}"
}

# Update the system
perform_action "Check for security updates" "yum update -qy --security"

# Configure umask
perform_action "Configure umask" "echo 'umask 027' >> /etc/profile"

# Check password quality and password policy
perform_action "Check password quality and policy" "sed -i 's/password requisite pam_pwquality.so try_first_pass local_users_only/password requisite pam_passwdqc.so min=disabled,disabled,16,12,8/' /etc/security/pwquality.conf && sed -i 's/password requisite pam_pwquality.so try_first_pass local_users_only/password requisite pam_passwdqc.so min=disabled,disabled,16,12,8/' /etc/pam.d/system-auth"

# Configure SELinux
perform_action "Configure SELinux" "setenforce 1 && sed -i 's/SELINUX=permissive/SELINUX=enforcing/g' /etc/selinux/config"

# Configure firewall (firewall-cmd)
perform_action "Configure firewall" "firewall-cmd --zone=public --add-port=22/tcp --permanent && firewall-cmd --zone=public --add-masquerade --permanent && firewall-cmd --zone=public --add-drop --permanent && firewall-cmd --reload"

# Configure SSH
perform_action "Configure SSH" "cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak && sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config"

# Configure auditd
perform_action "Configure auditd" "echo '-w /etc/passwd -p wa -k passwd_changes' >> /etc/audit/audit.rules && systemctl restart auditd"

# Configure Apache HTTP server
perform_action "Install and configure Apache HTTP server" "yum install -y httpd && systemctl start httpd"

# Backup important configuration files
backup_files "/etc/passwd"
backup_files "/etc/ssh/sshd_config"
backup_files "/etc/audit/audit.rules"

