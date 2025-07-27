#!/bin/bash
# strategize_project.sh - Converts goals into logical strategies

set -euo pipefail
IFS=$'\n\t'

# Determine project root if not already set, making the script more portable.
if [[ -z "${PRISM_QUANTA_ROOT:-}" ]]; then
    PRISM_QUANTA_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." &>/dev/null && pwd)"
fi

# Generate and source the environment file
ENV_SCRIPT="/tmp/prismquanta_env_strat.sh"
"$PRISM_QUANTA_ROOT/scripts/generate_env.sh" "$PRISM_QUANTA_ROOT/environment.txt" "$ENV_SCRIPT" "$PRISM_QUANTA_ROOT"
source "$ENV_SCRIPT"

echo "[STRATEGY] Reading goals from $PROJECT_GOALS_FILE..."

if [[ ! -f "$PROJECT_GOALS_FILE" ]]; then
    echo "[ERROR] No project goals file found!"
    exit 1
fi

cat "$PROJECT_GOALS_FILE" | "$LLM_INFER_SCRIPT" --prompt "Break these goals into sub-strategies:" > "$STRATEGY_PLAN_FILE"

echo "[STRATEGY] Plan saved to $STRATEGY_PLAN_FILE."
