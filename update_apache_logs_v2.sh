#!/bin/bash

# Define variables
LOG_DIR="/shared-storage/server_logs"
LOG_USER="deploy"
LOG_GROUP="deploy"
APACHE_CONF_DIR="/etc/apache2/sites-available"
MODIFIED_FILES_LOG="/tmp/modified_apache_conf_files.log"
BACKUP_DIR="/etc/apache2/sites-available/backup_$(date +%Y%m%d%H%M%S)"
DOMAINS_FILE="domains2.txt"

# Create the log directory if it doesn't exist
mkdir -p "$LOG_DIR"

# Create the backup directory
mkdir -p "$BACKUP_DIR"

# Clear the log file if it exists
> "$MODIFIED_FILES_LOG"

# Check if the domains file exists
if [ ! -f "$DOMAINS_FILE" ]; then
    echo "Domains file not found: $DOMAINS_FILE" 1>&2
    exit 1
fi

# Read domains from the file
while IFS= read -r domain; do
    # Skip comments and empty lines
    if [[ "$domain" =~ ^#.* ]] || [[ -z "$domain" ]]; then
        continue
    fi

    echo "Processing domain: $domain"

    # Define configuration file names
    conf_file="$APACHE_CONF_DIR/000-${domain}.conf"
    ssl_conf_file="$APACHE_CONF_DIR/000-${domain}-le-ssl.conf"

    # Define the log paths
    error_log_path="$LOG_DIR/${domain}.error.log"
    access_log_path="$LOG_DIR/${domain}.access.log"

    # Check and update the standard configuration file
    if [[ -f "$conf_file" ]]; then
        echo "Processing standard configuration file: $conf_file"

        # Create the log files if they don't exist
        touch "$error_log_path" "$access_log_path"

        # Change ownership of log files
        chown "$LOG_USER:$LOG_GROUP" "$error_log_path" "$access_log_path"

        # Backup the original configuration file
        cp "$conf_file" "$BACKUP_DIR/"

        # Apply sed commands to update log paths
        sed -i "s|ErrorLog .*|ErrorLog $error_log_path|g" "$conf_file"
        sed -i "s|CustomLog .*|CustomLog $access_log_path combined|g" "$conf_file"

        # Log the modified file
        echo "$conf_file" >> "$MODIFIED_FILES_LOG"
    fi

    # Check and update the SSL configuration file
    if [[ -f "$ssl_conf_file" ]]; then
        echo "Processing SSL configuration file: $ssl_conf_file"

        # Create the log files if they don't exist
        touch "$error_log_path" "$access_log_path"

        # Change ownership of log files
        chown "$LOG_USER:$LOG_GROUP" "$error_log_path" "$access_log_path"

        # Backup the original configuration file
        cp "$ssl_conf_file" "$BACKUP_DIR/"

        # Apply sed commands to update log paths
        sed -i "s|ErrorLog .*|ErrorLog $error_log_path|g" "$ssl_conf_file"
        sed -i "s|CustomLog .*|CustomLog $access_log_path combined|g" "$ssl_conf_file"

        # Log the modified file
        echo "$ssl_conf_file" >> "$MODIFIED_FILES_LOG"
    fi
done < "$DOMAINS_FILE"

# Reload Apache
echo "Reloading Apache..."
#systemctl reload apache2

echo "Webserver configuration complete for all domains. Modified configuration files are logged in $MODIFIED_FILES_LOG."
echo "Backup of original configuration files is stored in $BACKUP_DIR."
