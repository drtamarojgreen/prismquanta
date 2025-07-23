#!/bin/bash
# strategize_project.sh - Converts goals into logical strategies

INPUT="memory/project_goals.txt"
OUTPUT="memory/strategy_plan.txt"

echo "[STRATEGY] Reading goals from $INPUT..."

if [[ ! -f "$INPUT" ]]; then
    echo "[ERROR] No project goals file found!"
    exit 1
fi

# Sample prompt to LLM (replace with ./llm_infer.sh or similar)
cat "$INPUT" | ./llm_infer.sh --prompt "Break these goals into sub-strategies:" > "$OUTPUT"

echo "[STRATEGY] Plan saved to $OUTPUT."
