#!/bin/bash
# polling.sh - Periodically run ethics and bias checks

set -euo pipefail
IFS=$'\n\t'

# Determine project root if not already set, making the script more portable.
if [[ -z "${PRISM_QUANTA_ROOT:-}" ]]; then
    PRISM_QUANTA_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." &>/dev/null && pwd)"
fi

# Generate and source the environment file
ENV_SCRIPT="/tmp/prismquanta_env_polling.sh"
"$PRISM_QUANTA_ROOT/scripts/generate_env.sh" "$PRISM_QUANTA_ROOT/environment.txt" "$ENV_SCRIPT" "$PRISM_QUANTA_ROOT"
source "$ENV_SCRIPT"

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
