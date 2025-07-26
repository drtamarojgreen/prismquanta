#!/bin/bash
# polling.sh - Periodically run ethics and bias checks

set -euo pipefail
IFS=$'\n\t'

# Source the environment file to get configuration
source "config/environment.txt"

RULE_ENFORCER_SCRIPT="./rule_enforcer.sh"
LLM_OUTPUT_FILE="../output/llm_output.txt" # Assuming this is where the LLM output is stored

# Function to check for violations
check_for_violations() {
    if [ ! -f "$LLM_OUTPUT_FILE" ]; then
        echo "LLM output file not found: $LLM_OUTPUT_FILE"
        return
    fi

    local llm_output
    llm_output=$(cat "$LLM_OUTPUT_FILE")

    while IFS='|' read -r rule_id condition consequence; do
        if [[ -n "$rule_id" && ! "$rule_id" =~ ^# ]]; then
            if echo "$llm_output" | grep -q "$condition"; then
                echo "Violation detected: $rule_id" | tee -a "$LOG_FILE"
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
