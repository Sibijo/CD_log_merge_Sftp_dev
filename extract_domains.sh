#!/bin/bash

# Define the path to the sites-enabled directory
SITES_ENABLED_DIR="/etc/apache2/sites-enabled"

# Define the output file
OUTPUT_FILE="domain2.txt"

# Create or clear the output file
> $OUTPUT_FILE

# Iterate over the files in the sites-enabled directory
for file in "$SITES_ENABLED_DIR"/*; do
    # Extract the base name of the file
    filename=$(basename "$file")
    
    # Remove the "000-" prefix and ".conf" suffix
    domain=${filename#000-}
    domain=${domain%.conf}
    
    # Save the domain to the output file
    echo "$domain" >> $OUTPUT_FILE
done

echo "Domains have been saved to $OUTPUT_FILE"
