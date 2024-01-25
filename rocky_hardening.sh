#!/bin/bash

# Pobieranie aktualizacji systemu 
yum update -qy --security

# Konfiguracja dostępu do plików i katalogów
chmod 755 /path/to/directory

# Konfiguracja umask
echo "umask 027" >> /etc/profile

# Sprawdzanie jakości haseł i polityki haseł
sed -i 's/password requisite pam_pwquality.so try_first_pass local_users_only/password requisite pam_passwdqc.so min=disabled,disabled,16,12,8/' /etc/security/pwquality.conf
sed -i 's/password requisite pam_pwquality.so try_first_pass local_users_only/password requisite pam_passwdqc.so min=disabled,disabled,16,12,8/' /etc/pam.d/system-auth

# Konfiguracja SELinux
setenforce 1
sed -i 's/SELINUX=permissive/SELINUX=enforcing/g' /etc/selinux/config

# Konfiguracja firewalla (firewall-cmd)
firewall-cmd --zone=public --add-port=22/tcp --permanent
firewall-cmd --zone=public --add-masquerade --permanent
firewall-cmd --zone=public --add-drop --permanent
firewall-cmd --reload

# Konfiguracja SSH
backup_files /etc/ssh/sshd_config
sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config

# Konfiguracja auditd
#echo "-w /etc/passwd -p wa -k passwd_changes" >> /etc/audit/audit.rules
#systemctl restart auditd

# Konfiguracja Apache HTTP server
yum install -y httpd
systemctl start httpd
systemctl enable httpd

echo "Skrypt hardeningowy zakończony."
