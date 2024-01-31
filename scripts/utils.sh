#!/bin/bash

info() { echo -e "\e[32m[INFO]\e[0m ${1}" ; }
warn() { echo -e "\e[33m[WARN]\e[0m ${1}" ; }
error() { echo -e "\e[31m[ERROR]\e[0m ${1}" ; }

exit_on_fail() {
    exit_code=$?
    exit_message="$1"
    ignored_codes=("${@:2}")

    if [ $exit_code -ne 0 ] && [[ ! ${ignored_codes[*]} =~ $exit_code ]]; then
        error "$exit_message"
        warn "Exiting the script with exit code $exit_code"
        exit $exit_code
    fi
}

perform_action() {
    local action_description="$1"
    local action_command="$2"
    local package_name="$3"

    if [ -n "$package_name" ]; then
        if yum list installed "$package_name" >/dev/null 2>&1; then
            info "Package $package_name is already installed. Skipping action: $action_description"
            return
        fi
    fi

    info "Performing: ${action_description}..."
    ${action_command}

    exit_on_fail "Failed to ${action_description}"

    info "${action_description} completed successfully"
}

backup_files() {
    local src="$1"
    local dest="./hardening_backup/$(date +%Y%m%d_%H%M%S)"

    info "Backing up ${src} to ${dest}..."
    mkdir -p "${dest}"
    cp -a "${src}" "${dest}"
    exit_on_fail "Failed to create backup of ${src}"

    info "Backup created successfully at ${dest}"
}

log_message() {
    local log_level="$1"
    local message="$2"

    echo "$(date +'%Y-%m-%d %H:%M:%S') [$log_level] - ${message}"
}

create_directory() {
    local directory="$1"

    if [ ! -d "$directory" ]; then
        mkdir -p "$directory"
        exit_on_fail "Failed to create directory: $directory"
        log_message "INFO" "Directory created: $directory"
    else
        log_message "INFO" "Directory already exists: $directory"
    fi
}