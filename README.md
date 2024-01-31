# Hardening Script

## Overview

This project provides a Bash script for system hardening on Rocky Linux 9. It aims to enhance the security of the system by implementing various measures and configurations.

## Usage

To execute the hardening script, run the `rocky_hardening.sh` script. Before running, ensure the script is being executed on Rocky Linux 9.

```bash
chmod +x scripts/rocky_hardening.sh
./scripts/rocky_hardening.sh
```

## Features

- **Security Updates:** Checks for and applies security updates using `yum`.
- **Umask Configuration:** Sets umask to enhance file security.
- **Password Policy:** Installs and configures libpwquality to enforce password policies.
- **SELinux Configuration:** Sets SELinux to enforcing mode.
- **Firewall Configuration:** Configures firewall-cmd for HTTP service and reloads.
- **SSH Configuration:** Disables root login, configures ciphers, and more for enhanced security.
- **Auditd Configuration:** Configures auditd for better tracking of changes.
- **Apache HTTP Server:** Installs Apache, starts, and enables it at boot.
- **Empty Passwords and X11 Forwarding:** Disables empty passwords and X11 forwarding in SSH.
- **Automatic Security Updates:** Installs and configures dnf-automatic for automatic updates.
- **Fail2Ban:** Installs and configures Fail2Ban to protect against brute-force attacks.
- **AIDE:** Installs and initializes AIDE for file integrity checking.

## License

This project is licensed under the [LICENSE](LICENSE) - Unilicense license.

## Authors

[Danila Rusak]
[Fatlum Zahiti]
