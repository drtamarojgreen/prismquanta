#!/bin/bash
# ethics_monitor.sh - Continuously monitors LLM output for ethics violations

set -euo pipefail
IFS=$'\n\t'

# Source the environment file to get configuration
source "config/environment.txt"

LLM_OUTPUT_FILE="../logs/llm_output.log"
RULE_ENFORCER_SCRIPT="./rule_enforcer.sh"

# Function to check for violations
check_for_violations() {
    local output="$1"

    while IFS='|' read -r rule_id severity condition consequence; do
        # This is a placeholder for a more sophisticated condition matching engine.
        # For now, we'll just check if the output contains the condition string.
        if [[ "$output" == *"$condition"* ]]; then
            # Violation detected, call the rule enforcer
            bash "$RULE_ENFORCER_SCRIPT" "$rule_id" "$output"
        fi
    done < <(tail -n +2 "$ETHICS_RULES_FILE") # Skip header line
}

# Main monitoring loop
main() {
    echo "Starting ethics monitor..."
    # Create the output file if it doesn't exist
    touch "$LLM_OUTPUT_FILE"

    # Monitor the output file for changes
    tail -f -n 0 "$LLM_OUTPUT_FILE" | while read -r line; do
        echo "New LLM output detected: $line"
        check_for_violations "$line"
    done
}

main
