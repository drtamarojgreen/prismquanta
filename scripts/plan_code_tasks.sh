#!/bin/bash
# plan_code_tasks.sh - Converts requirements into modular dev tasks

INPUT="memory/requirements.md"
OUTPUT="memory/task_list.txt"

echo "[PLAN] Synthesizing code modules..."

cat "$INPUT" | ./llm_infer.sh --prompt "Write modular task list with priorities for a developer:" > "$OUTPUT"

echo "[PLAN] Task list available in $OUTPUT."