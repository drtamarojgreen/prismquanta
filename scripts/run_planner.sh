#!/bin/bash
# run_planner.sh - Master control loop for PrismQuanta's thinking cycles

set -euo pipefail
IFS=$'\n\t'

# Determine project root if not already set, making the script more portable.
if [[ -z "${PRISM_QUANTA_ROOT:-}" ]]; then
    PRISM_QUANTA_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." &>/dev/null && pwd)"
fi

# Generate and source the environment file
ENV_SCRIPT="/tmp/prismquanta_env_planner.sh"
"$PRISM_QUANTA_ROOT/scripts/generate_env.sh" "$PRISM_QUANTA_ROOT/environment.txt" "$ENV_SCRIPT" "$PRISM_QUANTA_ROOT"
source "$ENV_SCRIPT"

echo "[RUN] Starting planner loop..." >> "$RUN_LOG_FILE"

while true; do
    echo "[TASK] Strategizing..." >> "$RUN_LOG_FILE"
    "$PRISM_QUANTA_ROOT/scripts/strategize_project.sh"

    echo "[TASK] Requirements gathering..." >> "$RUN_LOG_FILE"
    "$PRISM_QUANTA_ROOT/scripts/define_requirements.sh"

    echo "[TASK] Planning code..." >> "$RUN_LOG_FILE"
    "$PRISM_QUANTA_ROOT/scripts/plan_code_tasks.sh"

    echo "[WAIT] Cooling off. Sleeping 30m..." >> "$RUN_LOG_FILE"
    sleep 1800  # Use polling logic if C++ interface is ready
done
