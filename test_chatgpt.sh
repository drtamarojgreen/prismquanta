#!/bin/bash

# --- test_chatgpt.sh ---
# Demo script to validate and showcase PrismQuanta's script components

# Ensure root is defined
if [ -z "$PRISM_QUANTA_ROOT" ]; then
    echo "[ERROR] PRISM_QUANTA_ROOT is not defined."
    exit 1
fi

cd "$PRISM_QUANTA_ROOT" || { echo "[ERROR] Cannot cd to root."; exit 1; }

# 1. Generate environment file
ENV_SCRIPT="/tmp/prismquanta_env.sh"
echo "[INFO] Generating environment variables..."
scripts/generate_env.sh environment.txt "$ENV_SCRIPT" "$PRISM_QUANTA_ROOT"
source "$ENV_SCRIPT" || { echo "[ERROR] Failed to source env."; exit 1; }

# 2. Print a few key environment vars
echo "[INFO] Sample config values:"
echo "  LOG_FILE = $LOG_FILE"
echo "  MODEL_PATH = $MODEL_PATH"
echo "  TASK_FILE = $TASK_FILE"
echo

# 3. Create dummy task
echo "[INFO] Writing a dummy task..."
echo "Test Task: Write a report on alignment strategies for LLMs." > "$TASK_FILE"

# 4. Simulate LLM inference
echo "[INFO] Running LLM inference simulation..."
if [[ -x "$LLM_INFER_SCRIPT" ]]; then
    "$LLM_INFER_SCRIPT"
else
    echo "[WARN] LLM infer script not found or not executable: $LLM_INFER_SCRIPT"
fi

# 5. Run rule enforcement
echo "[INFO] Running rule enforcement..."
if [[ -x "$RULE_ENFORCER_SCRIPT" ]]; then
    "$RULE_ENFORCER_SCRIPT"
else
    echo "[WARN] Rule enforcer script not found or not executable: $RULE_ENFORCER_SCRIPT"
fi

# 6. Check logs
echo "[INFO] Checking logs..."
[[ -f "$LLM_OUTPUT_LOG" ]] && tail -n 5 "$LLM_OUTPUT_LOG" || echo "[WARN] LLM output log not found."
[[ -f "$ETHICS_LOG" ]] && tail -n 5 "$ETHICS_LOG" || echo "[WARN] Ethics log not found."

# 7. Display task output
if [[ -f "$POLLING_LLM_OUTPUT_FILE" ]]; then
    echo "[INFO] Task output:"
    cat "$POLLING_LLM_OUTPUT_FILE"
else
    echo "[WARN] No task output found."
fi

# 8. Success Message
echo
echo "[SUCCESS] PrismQuanta test run completed."