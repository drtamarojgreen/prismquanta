#!/bin/bash
# strategize_project.sh - Converts goals into logical strategies

# Source the environment file to get configuration
source "config/environment.txt"

echo "[STRATEGY] Reading goals from $PROJECT_GOALS_FILE..."

if [[ ! -f "$PROJECT_GOALS_FILE" ]]; then
    echo "[ERROR] No project goals file found!"
    exit 1
fi

# Sample prompt to LLM (replace with ./llm_infer.sh or similar)
cat "$PROJECT_GOALS_FILE" | ./llm_infer.sh --prompt "Break these goals into sub-strategies:" > "$STRATEGY_PLAN_FILE"

echo "[STRATEGY] Plan saved to $STRATEGY_PLAN_FILE."
