#!/bin/bash
# define_requirements.sh - Expands strategies into clear, testable requirements

# Source the environment file to get configuration
source "config/environment.txt"

echo "[REQ] Generating requirements from strategies..."

cat "$STRATEGY_PLAN_FILE" | ./llm_infer.sh --prompt "Define testable requirements from this plan:" > "$REQUIREMENTS_FILE"

echo "[REQ] Requirements written to $REQUIREMENTS_FILE."
