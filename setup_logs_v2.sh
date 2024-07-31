#!/bin/bash

# Define variables
LOG_DIR="/home/sftpuser/server_logs"
EFS_LOG_DIR="/efs-prod/server_logs"
USER="sftpuser"
DOMAIN_FILE="domains2.txt"

# Check if the domain file exists
if [ ! -f "$DOMAIN_FILE" ]; then
    echo "Domain file not found: $DOMAIN_FILE" 1>&2
    exit 1
fi

# Ensure the target directory exists
if [ ! -d "$LOG_DIR" ]; then
    echo "Creating target directory: $LOG_DIR"
    mkdir -p "$LOG_DIR"
    if [ $? -ne 0 ]; then
        echo "Failed to create directory: $LOG_DIR" 1>&2
        exit 1
    fi
fi

# Change ownership of the target directory to sftpuser
echo "Changing ownership of $LOG_DIR to $USER"
sudo chown $USER:$USER "$LOG_DIR"
if [ $? -ne 0 ]; then
    echo "Failed to change ownership of $LOG_DIR" 1>&2
    exit 1
fi

# Create symbolic links for each domain
while IFS= read -r DOMAIN; do
    if [ -n "$DOMAIN" ]; then
        echo "Creating links for domain: $DOMAIN"
        sudo -u ${USER} ln -sf ${EFS_LOG_DIR}/${DOMAIN}.error.log ${LOG_DIR}/${DOMAIN}.error.log
        sudo -u ${USER} ln -sf ${EFS_LOG_DIR}/${DOMAIN}.access.log ${LOG_DIR}/${DOMAIN}.access.log
    fi
done < "$DOMAIN_FILE"

echo "Symbolic links created for all domains as ${USER}."
