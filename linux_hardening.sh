#!/bin/bash

source utils.sh

info "Hardening script by Danilla and Fafa"
mkdir -p "$dest"
# Pobieranie aktualizacji systemu (security) 
info "Checking for security updates available..."
#yum update -qy --security
info "Security updates checked"

# Password policy 


# Firewall and network 


# SSH configuration 
backup_files /etc/ssh/sshd_config
sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i '$a Ciphers aes256-gcm@openssh.com,aes128-gcm@openssh.com,chacha20-poly1305@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr
' /etc/ssh/sshd_config


# Selinux enable


