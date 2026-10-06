# EZ WP Setup // 🚀 Quick WordPress Install

![EZ WP Setup Installer](assets/installer.png)

[![Platform: WSL2 / Linux](https://img.shields.io/badge/Platform-WSL2%20%7C%20Linux-purple.svg)](https://ubuntu.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![OS: Ubuntu/Debian](https://img.shields.io/badge/OS-Ubuntu%20%7C%20Debian-orange.svg)](https://ubuntu.com/)
[![Shell: Bash](https://img.shields.io/badge/Shell-Bash-blue.svg)](https://www.gnu.org/software/bash/)
[![WordPress: Latest](https://img.shields.io/badge/WordPress-Latest-blue.svg)](https://wordpress.org/download/)

A lightweight helper for **instant WordPress installation** on fresh **WSL2**, Ubuntu, and Debian systems. Provisions a complete, fully tuned LAMP stack and the latest WordPress release in under 60 seconds with an interactive CLI installer.

## ✨ Scripts Included

- **`install_fresh_mariadb.sh`**: Ultra-fast WordPress installation with **MariaDB** *(Recommended)*.
- **`install_fresh_mysql.sh`**: WordPress setup using standard **MySQL**.

---

## ⚡ Quick Start (Fresh WSL / Ubuntu)

Open your fresh WSL2 or Ubuntu terminal and run one of the commands below:

> [!IMPORTANT]
> Must be executed with `sudo` or as `root` on a fresh, clean environment.

### Option 1: MariaDB (Recommended)
```bash
curl -sSL https://raw.githubusercontent.com/Evgenii-Zinner/ez_wp_setup/master/install_fresh_mariadb.sh -o setup.sh && chmod +x setup.sh && sudo ./setup.sh
```
*Or using `wget`:*
```bash
wget -q -O setup.sh https://raw.githubusercontent.com/Evgenii-Zinner/ez_wp_setup/master/install_fresh_mariadb.sh && chmod +x setup.sh && sudo ./setup.sh
```

### Option 2: MySQL
```bash
curl -sSL https://raw.githubusercontent.com/Evgenii-Zinner/ez_wp_setup/master/install_fresh_mysql.sh -o setup.sh && chmod +x setup.sh && sudo ./setup.sh
```

---

## 🌐 Accessing Your WordPress Site

Once installation finishes, your generated database credentials and access URL will be displayed in a terminal summary box:

1. Open your browser on Windows or Linux:
   - **`http://localhost`** *(default on WSL2)*
   - or the specific IP displayed at the end (e.g., `http://172.x.x.x`).
2. Complete the standard 1-minute WordPress web setup (select site title, admin username, and password).

---

## 🛠 What It Provisions

- **Full LAMP Stack**: Apache2, PHP 8+ with all required WP extensions (`curl`, `gd`, `mbstring`, `xml`, `zip`, `imagick`, etc.).
- **Database Engine**: MariaDB or MySQL configured with `utf8mb4` encoding and dedicated WP database + user.
- **WordPress Core**: Latest official release downloaded and unpacked to `/var/www/html/`.
- **Config & Security**: Generates fresh cryptographic salts from the official WordPress API and configures `wp-config.php`.
- **Web Server Ready**: Enables Apache `mod_rewrite` and `AllowOverride All` so pretty permalinks work immediately.
- **Permissions**: Sets proper `www-data:www-data` ownership.

---

## 🖥 Environment Notes

- **WSL2**: Requires systemd enabled (default in modern WSL2). Run inside your WSL Ubuntu terminal and access directly via `http://localhost` from Windows.
- **Virtual Machines (VirtualBox, Proxmox, VMware)**: Use **Bridge Mode** networking so the guest IP is reachable from your host machine.

---

## 🤝 Contributing

Feel free to open an issue or add new scripts for other installations (e.g., Nginx, Redis, specific PHP versions). Your contributions help make this the best **easy WordPress install** tool!

---

## 📜 License

[MIT License](LICENSE) - Copyright (c) 2026 [Evgenii Zinner](https://github.com/Evgenii-Zinner)
