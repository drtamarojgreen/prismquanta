#!/bin/bash
# define_requirements.sh - Expands strategies into clear, testable requirements

INPUT="memory/strategy_plan.txt"
OUTPUT="memory/requirements.md"

echo "[REQ] Generating requirements from strategies..."

cat "$INPUT" | ./llm_infer.sh --prompt "Define testable requirements from this plan:" > "$OUTPUT"

echo "[REQ] Requirements written to $OUTPUT."
