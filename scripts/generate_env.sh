#!/bin/bash

# This script generates a shell script with environment variables from the config file.

CONFIG_FILE="$1"
OUTPUT_FILE="$2"
PROJECT_ROOT="$3"

if [[ -z "$PROJECT_ROOT" ]]; then
    echo "Error: Project root (argument 3) is required." >&2
    exit 1
fi

# Clear the output file
> "$OUTPUT_FILE"

while IFS='=' read -r key value; do
    # Skip comments and empty lines
    case "$key" in
        ''|\#*) continue ;;
    esac
    key=$(echo "$key" | tr -d ' ' | tr -d '"')
    value=$(echo "$value" | tr -d ' ' | tr -d '"')

    # Handle the special case for PROJECT_ROOT itself
    if [[ "$key" == "PROJECT_ROOT" && "$value" == "." ]]; then
        echo "export PROJECT_ROOT=\"$PROJECT_ROOT\"" >> "$OUTPUT_FILE"
    else
        # Remove leading './' from value if it exists, as it's redundant
        value="${value#./}"
        echo "export $key=\"$PROJECT_ROOT/$value\"" >> "$OUTPUT_FILE"
    fi
done < "$CONFIG_FILE"
