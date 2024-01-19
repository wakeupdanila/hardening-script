#!/bin/bash

info () { echo -e "\e[32m[INFO]\e[0m ${1}" ; }
warn () { echo -e "\e[33m[WARN]\e[0m ${1}" ; }
error () { echo -e "\e[31m[ERROR]\e[0m ${1}" ; }
home_dir () { getent passwd "$1" | cut -d: -f6 ; } # https://superuser.com/questions/484277/get-home-directory-by-username
user_group () { id -G $1 ; }

exit_on_fail () {
    exit_code=$?
    exit_message="$1"
    ignored_codes=$2

    if [ $exit_code -ne 0 ] && [[ ! ${ignored_codes[*]} =~ $exit_code ]]; then
        error "$exit_message"
        warn "Exiting the script"
        exit $exit_code
    fi
}


# Example usage of the function: 
# backup_file "/path/to/source/file_or_directory" "/path/to/destination"

backup_dir="/tmp/hardening_backup"

backup_files () {
    local src=$1
    local dest="$backup_dir"
    
    # Define backup filename with timestamp
    local filename=$(basename "$src")
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_name="${filename}_backup_${timestamp}"
    return 0
}

check_root () {
	if [ $(id -u) -ne 0 ]; then
		error "Please run as root" 
		exit 1
	fi 
}


# Creates the backup dir 
check_root
mkdir -p "$backup_dir"

# Pobieranie aktualizacji systemu (security) 
warn "Checking for security updates available..." 
yum update -qy --security
info "Security updates checked"
backup_files /etc/sshd 
