#!/bin/bash

# Define the output file
DOMAIN_FILE="domains2.txt"

# Extract domain names, remove comments and empty lines
grep -rE "ServerName|ServerAlias" /etc/apache2/sites-available /etc/apache2/sites-enabled | \
awk '{print $2}' | \
sort | \
uniq | \
grep -vE "^#" | \
grep -vE "^\s*$" > "$DOMAIN_FILE"

echo "Domains have been saved to $DOMAIN_FILE."
