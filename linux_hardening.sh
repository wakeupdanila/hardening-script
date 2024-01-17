#!/bin/bash

log_message() {
    echo "[ $(date '+%Y-%m-%d %H:%M:%S') ] $1"
}

# Create a backup
backup_file() {
    local file=$1
    local backup_file="$file.backup"
    cp "$file" "$backup_file"
    log_message "Backup created: $backup_file"
}

log_message "Starting Linux Hardening Script"

# Configure the access to files and directories
log_message "Configuring access to files and directories"
# chmod -R 755 !!!

# Configure umask
log_message "Configuring umask"
umask 022

# Check passwords quality and policy
log_message "Checking password quality and policy"
# !!!

# Configure SELinux
# !!!

# Configure firewall
log_message "Configuring firewall (iptables)"
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -j DROP

# Configure SSH
log_message "Configuring SSH"
# !!!

# Configure audit
log_message "Configuring audit"
auditctl -w /var/log/faillog -p wa
auditctl -w /var/log/lastlog -p wa

# Configure Apache HTTP server
log_message "Configuring Apache HTTP server"
# !!!

# Restart services
log_message "Restarting services"
systemctl restart sshd
systemctl restart apache2

log_message "Configurations applied successfully."

