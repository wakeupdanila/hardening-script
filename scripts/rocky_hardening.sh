#!/bin/bash

source utils.sh

# Update the system
info "Checking for security updates available..."
yum update -qy --security
info "Security updates checked"

# Configure umask
echo "umask 027" >> /etc/profile

# Check password quality and password policy
sed -i 's/password requisite pam_pwquality.so try_first_pass local_users_only/password requisite pam_passwdqc.so min=disabled,disabled,16,12,8/' /etc/security/pwquality.conf
sed -i 's/password requisite pam_pwquality.so try_first_pass local_users_only/password requisite pam_passwdqc.so min=disabled,disabled,16,12,8/' /etc/pam.d/system-auth

# Configure SELinux
setenforce 1
sed -i 's/SELINUX=permissive/SELINUX=enforcing/g' /etc/selinux/config

# Configure firewall (firewall-cmd)
firewall-cmd --zone=public --add-port=22/tcp --permanent
firewall-cmd --zone=public --add-masquerade --permanent
firewall-cmd --zone=public --add-drop --permanent
firewall-cmd --reload

# Configure SSH
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config

# Configure auditd
echo "-w /etc/passwd -p wa -k passwd_changes" >> /etc/audit/audit.rules
systemctl restart auditd

# Configure Apache HTTP server
yum install -y httpd
systemctl start httpd
systemctl enable httpd
