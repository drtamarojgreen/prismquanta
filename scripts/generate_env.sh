#!/bin/bash

# This script generates a shell script with environment variables from the config file.

CONFIG_FILE="$1"
OUTPUT_FILE="$2"
PROJECT_ROOT="$PRISM_QUANTA_ROOT"

# Clear the output file
> "$OUTPUT_FILE"

while IFS='=' read -r key value; do
    # Skip comments and empty lines
    case "$key" in
        ''|\#*) continue ;;
    esac
    key=$(echo "$key" | tr -d ' ' | tr -d '"')
    value=$(echo "$value" | tr -d ' ' | tr -d '"')
    echo "export $key=\"$PROJECT_ROOT/$value\"" >> "$OUTPUT_FILE"
done < "$CONFIG_FILE"
