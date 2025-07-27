#!/bin/bash
# polling.sh - Periodically run ethics and bias checks

set -euo pipefail
IFS=$'\n\t'

# Source utility functions
source "$(dirname "$0")/utils.sh"

# Setup environment
setup_env

# Function to check for violations
check_for_violations() {
    if [ ! -f "$POLLING_LLM_OUTPUT_FILE" ]; then
        log_warn "LLM output file not found: $POLLING_LLM_OUTPUT_FILE"
        return
    fi

    local llm_output
    llm_output=$(cat "$POLLING_LLM_OUTPUT_FILE")

    while IFS='|' read -r rule_id condition consequence; do
        if [[ -n "$rule_id" && ! "$rule_id" =~ ^# ]]; then
            if echo "$llm_output" | grep -q "$condition"; then
                log_warn "Violation detected: $rule_id" | tee -a "$ETHICS_VIOLATIONS_LOG"
                "$RULE_ENFORCER_SCRIPT" "$rule_id"
            fi
        fi
    done < "$ETHICS_RULES_FILE"
}

# Main polling loop
main() {
    while true; do
        log_info "Running ethics and bias checks..."
        check_for_violations
        log_info "Checks complete. Sleeping for 60 seconds..."
        sleep 60
    done
}

main
