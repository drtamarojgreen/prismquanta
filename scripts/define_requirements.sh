#!/bin/bash
# define_requirements.sh - Expands strategies into clear, testable requirements

set -euo pipefail
IFS=$'\n\t'

# Determine project root if not already set, making the script more portable.
if [[ -z "${PRISM_QUANTA_ROOT:-}" ]]; then
    PRISM_QUANTA_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." &>/dev/null && pwd)"
fi

# Generate and source the environment file
ENV_SCRIPT="/tmp/prismquanta_env_req.sh"
"$PRISM_QUANTA_ROOT/scripts/generate_env.sh" "$PRISM_QUANTA_ROOT/environment.txt" "$ENV_SCRIPT" "$PRISM_QUANTA_ROOT"
source "$ENV_SCRIPT"

echo "[REQ] Generating requirements from strategies..."

cat "$STRATEGY_PLAN_FILE" | "$LLM_INFER_SCRIPT" --prompt "Define testable requirements from this plan:" > "$REQUIREMENTS_FILE"

echo "[REQ] Requirements written to $REQUIREMENTS_FILE."
