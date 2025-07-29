#!/bin/bash

export PRISM_QUANTA_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"

if [ -f "$PRISM_QUANTA_ROOT/environment.txt" ]; then
    while IFS='=' read -r key value; do
        # Trim leading/trailing whitespace from key and value
        key=$(echo "$key" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
        value=$(echo "$value" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')

        # Ignore comments and empty lines
        if [[ -n "$key" && ! "$key" =~ ^# ]]; then
            export "$key=$value"
        fi
    done < "$PRISM_QUANTA_ROOT/environment.txt"
fi
