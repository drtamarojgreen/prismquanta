#!/bin/bash
# ethics_monitor.sh - Continuously monitors LLM output for ethics violations

set -euo pipefail
IFS=$'\n\t'

# Determine project root if not already set, making the script more portable.
if [[ -z "${PRISM_QUANTA_ROOT:-}" ]]; then
    PRISM_QUANTA_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." &>/dev/null && pwd)"
fi

# Generate and source the environment file
ENV_SCRIPT="/tmp/prismquanta_env_monitor.sh"
"$PRISM_QUANTA_ROOT/scripts/generate_env.sh" "$PRISM_QUANTA_ROOT/environment.txt" "$ENV_SCRIPT" "$PRISM_QUANTA_ROOT"
source "$ENV_SCRIPT"

# Function to check for violations
check_for_violations() {
    local output="$1"

    while IFS='|' read -r rule_id severity condition consequence; do
        # This is a placeholder for a more sophisticated condition matching engine.
        # For now, we'll just check if the output contains the condition string.
        if [[ "$output" == *"$condition"* ]]; then
            # Violation detected, call the rule enforcer
            "$RULE_ENFORCER_SCRIPT" "$rule_id" "$output"
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
