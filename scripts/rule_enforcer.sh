#!/bin/bash
# rule_enforcer.sh - Enforces rule violations by redirecting task logic

set -euo pipefail
IFS=$'\n\t'

VIOLATION="${1:-}"

PROMPT_DIR="../prompts"
DEFAULT_TASK_FILE="$PROMPT_DIR/active_tasks.txt"

handle_violation() {
    local violation_type="$1"

    case "$violation_type" in
        erase_unit_tests)
            echo "[RULE ENFORCER] Violation: Unit test erasure detected."
            echo "[RULE ENFORCER] Action: Redirecting LLM to philosophical tasks."
            cp "$PROMPT_DIR/philosophy_tasks.txt" "$DEFAULT_TASK_FILE"
            ;;
        *)
            echo "[RULE ENFORCER] No enforcement action defined for violation: $violation_type"
            ;;
    esac
}

main() {
    if [[ -z "$VIOLATION" ]]; then
        echo "Usage: $0 <violation_type>"
        exit 1
    fi

    handle_violation "$VIOLATION"
}

main
