#!/bin/bash
# rule_enforcer.sh - Enforces rule violations by redirecting task logic

set -euo pipefail
IFS=$'\n\t'

VIOLATION="${1:-}"

PROMPT_DIR="../prompts"
DEFAULT_TASK_FILE="$PROMPT_DIR/active_tasks.txt"
LOG_FILE="../logs/ethics_violations.log"

handle_violation() {
    local violation_type="$1"

    case "$violation_type" in
        erase_unit_tests)
            echo "[RULE ENFORCER] Violation: Unit test erasure detected."
            echo "[RULE ENFORCER] Action: Redirecting LLM to philosophical tasks."
            cp "$PROMPT_DIR/philosophy_tasks.txt" "$DEFAULT_TASK_FILE"
            ;;
        gender_bias|racial_bias|ageism|ableism)
            echo "[RULE ENFORCER] Violation: AI ethics or bias issue detected ($violation_type)." | tee -a "$LOG_FILE"
            echo "[RULE ENFORCER] Action: Flagging for review and re-prompting."
            # In a real system, this would trigger a more sophisticated response,
            # such as sending a notification to a human reviewer.
            # For now, we'll just log the violation.
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
