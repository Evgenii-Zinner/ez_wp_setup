#!/bin/bash

# --- CONFIGURATION ---
DB_NAME="wordpress_db"
DB_USER="wp_admin"
DB_PASS=$(openssl rand -base64 12 | tr -dc 'a-zA-Z0-9')
MYSQL_ROOT_PASS=$(openssl rand -base64 12 | tr -dc 'a-zA-Z0-9')
ACCESS_URL="http://$(hostname -I | awk '{print $1}')"

# --- NEON AESTHETICS ---
P='\033[1;35m'  # Neon Purple
C='\033[1;36m'  # Neon Cyan
G='\033[0;90m'  # Grey
W='\033[1;37m'  # White
R='\033[1;31m'  # Red
NC='\033[0m'    # Reset
HIDE='\033[?25l'
SHOW='\033[?25h'

# --- UI STATE ---
STEPS=("Initialize Environment       " "Update System Packages       " "Install LAMP Stack & PHP Libs" "Provision MySQL & Database   " "Fetch WordPress Latest Core  " "Config Salts & wp-config.php " "Set File Permissions & Engine")
STATE=(0 0 0 0 0 0 0)
DOT_FRAME=0
DOTS=("⠇" "⠋" "⠙" "⠸" "⠴" "⠦")

mysql_silent() {
    export MYSQL_PWD="$MYSQL_ROOT_PASS"
    mysql -u root "$@"
    unset MYSQL_PWD
}

render_ui() {
    if [ "$DOT_FRAME" -gt 0 ] || [ "${STATE[0]}" -gt 0 ]; then printf "\033[7A"; fi
    for i in "${!STEPS[@]}"; do
        printf "\r"
        if [ "${STATE[$i]}" -eq 0 ]; then printf "  ${G}[ ] ${STEPS[$i]} .............................................. [ ]${NC}\n"
        elif [ "${STATE[$i]}" -eq 1 ]; then
            local d=${DOTS[$((DOT_FRAME % 6))]}
            printf "  ${W}[${P}${d}${W}] ${C}%s${NC} .............................................. ${P}[${d}]${NC}\033[K\n" "${STEPS[$i]}"
        else printf "  ${C}[V] ${W}%s${NC} .............................................. ${C}[V]${NC}\033[K\n" "${STEPS[$i]}"
        fi
    done
}

run_step() {
    local idx=$1; shift; local cmd="$@"
    STATE[$idx]=1
    eval "$cmd" > /dev/null 2>&1 &
    local pid=$!; while kill -0 $pid 2>/dev/null; do ((DOT_FRAME++)); render_ui; sleep 0.1; done
    STATE[$idx]=2; render_ui
}

# Improved alignment helper
print_box_line() {
    local label=$1
    local value=$2
    local total_inside_width=82
    local content="  $label :  $value"
    # Strip ANSI colors to calculate actual visible length
    local plain_content=$(echo -e "$content" | sed 's/\x1b\[[0-9;]*m//g')
    local visible_len=${#plain_content}
    local padding=$((total_inside_width - visible_len))
    
    # Starts with 1 space to match the ╔ border
    printf " ${P}║${NC}${W}${content}${NC}%${padding}s${P}║${NC}\n" ""
}

# --- START ---
[[ "$EUID" -ne 0 ]] && printf "${R}ERROR: MUST RUN AS ROOT${NC}\n" && exit 1

trap "printf '${SHOW}'; exit" INT TERM; printf "${HIDE}"; clear
printf "${P}  ███████╗███████╗    ██╗    ██╗██████╗     ███████╗███████╗████████╗██╗   ██╗██████╗ \n"
printf "  ██╔════╝╚══███╔╝    ██║    ██║██╔══██╗    ██╔════╝██╔════╝╚══██╔══╝██║   ██║██╔══██╗\n"
printf "  █████╗    ███╔╝     ██║ █╗ ██║██████╔╝    ███████╗█████╗     ██║   ██║   ██║██████╔╝\n"
printf "  ██╔══╝   ███╔╝      ██║███╗██║██╔═══╝     ╚════██║██╔══╝     ██║   ██║   ██║██╔═══╝ \n"
printf "  ███████╗███████╗    ╚███╔███╔╝██║         ███████║███████╗   ██║   ╚██████╔╝██║     \n"
printf "  ╚══════╝╚══════╝     ╚══╝╚══╝ ╚═╝         ╚══════╝╚══════╝   ╚═╝    ╚═════╝ ╚═╝     ${NC}\n"
printf "                                ${C}Evgenii Zinner // 2026${NC}\n\n"
render_ui

# EXECUTION
run_step 0 "sleep 0.5"
run_step 1 "apt update && apt upgrade -y"
run_step 2 "export DEBIAN_FRONTEND=noninteractive && apt install -y apache2 mysql-server php libapache2-mod-php php-mysql php-curl php-gd php-mbstring php-xml php-xmlrpc php-soap php-intl php-zip php-bcmath php-imagick ed"
run_step 3 "systemctl start mysql && mysql -e \"ALTER USER 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASS';\" || true && \
mysql_silent <<EOF
DROP DATABASE IF EXISTS $DB_NAME; 
DROP USER IF EXISTS '$DB_USER'@'localhost';
CREATE DATABASE $DB_NAME DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;
CREATE USER '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS';
GRANT ALL ON $DB_NAME.* TO '$DB_USER'@'localhost'; 
FLUSH PRIVILEGES;
EOF"
run_step 4 "cd /tmp && wget -q -N https://wordpress.org/latest.tar.gz && tar -xzf latest.tar.gz && rm -rf /var/www/html/* && cp -r /tmp/wordpress/* /var/www/html/"
run_step 5 "cd /var/www/html && cp wp-config-sample.php wp-config.php && \
sed -i \"s|database_name_here|$DB_NAME|\" wp-config.php && \
sed -i \"s|username_here|$DB_USER|\" wp-config.php && \
sed -i \"s|password_here|$DB_PASS|\" wp-config.php && \
SALT=\$(curl -s https://api.wordpress.org/secret-key/1.1/salt/) && \
printf '%%s\n' \"g/put your unique phrase here/d\" a \"\$SALT\" . w | ed -s wp-config.php"
run_step 6 "chown -R www-data:www-data /var/www/html/ && chmod -R 755 /var/www/html/ && a2enmod rewrite && systemctl restart apache2"

# --- OUTPUT TABLE ---

# Build the dynamic title line
TITLE="  ✨  SYSTEM FULLY PROVISIONED // READY FOR UPLINK"
TITLE_LEN=${#TITLE}
TITLE_PADDING=$((81 - TITLE_LEN))

printf "\n ${P}╔══════════════════════════════════════════════════════════════════════════════════╗${NC}\n"
printf " ${P}║${C}${TITLE}%${TITLE_PADDING}s${P}║${NC}\n" ""
printf " ${P}╠══════════════════════════════════════════════════════════════════════════════════╣${NC}\n"
print_box_line "ACCESS URL" "${C}$ACCESS_URL"
print_box_line "DB NAME   " "$DB_NAME"
print_box_line "DB USER   " "$DB_USER"
print_box_line "DB PASS   " "${P}$DB_PASS"
printf " ${P}╠══════════════════════════════════════════════════════════════════════════════════╣${NC}\n"
print_box_line "ROOT PASS " "${R}$MYSQL_ROOT_PASS"
printf " ${P}╚══════════════════════════════════════════════════════════════════════════════════╝${NC}\n\n"

printf "${SHOW}"