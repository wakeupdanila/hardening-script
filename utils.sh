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


dest="./hardening_backup/$(date +%Y%m%d_%H%M%S)"
backup_files () {
    local src="$1"

    # Define backup filename with timestamp
    local backup_name="${src}_backup"

    # Perform the backup
    cp -a "$src" "${dest}"

    return 0
}

