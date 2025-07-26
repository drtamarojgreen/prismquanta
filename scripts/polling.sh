#!/bin/bash
# polling.sh - Periodically run ethics and bias checks

set -euo pipefail
IFS=$'\n\t'

# Source the environment file to get configuration
source "config/environment.txt"

# Function to check for violations
check_for_violations() {
    if [ ! -f "$POLLING_LLM_OUTPUT_FILE" ]; then
        echo "LLM output file not found: $POLLING_LLM_OUTPUT_FILE"
        return
    fi

    local llm_output
    llm_output=$(cat "$POLLING_LLM_OUTPUT_FILE")

    while IFS='|' read -r rule_id condition consequence; do
        if [[ -n "$rule_id" && ! "$rule_id" =~ ^# ]]; then
            if echo "$llm_output" | grep -q "$condition"; then
                echo "Violation detected: $rule_id" | tee -a "$ETHICS_VIOLATIONS_LOG"
                "$RULE_ENFORCER_SCRIPT" "$rule_id"
            fi
        fi
    done < "$ETHICS_RULES_FILE"
}

# Main polling loop
main() {
    while true; do
        echo "Running ethics and bias checks..."
        check_for_violations
        echo "Checks complete. Sleeping for 60 seconds..."
        sleep 60
    done
}

main
