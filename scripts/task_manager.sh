#!/bin/bash
# task_manager.sh
#
# PrismQuanta Task Manager
# Manages a queue of AI tasks, runs the LLM, enforces behavior rules, and saves outputs.
#
# Usage: ./task_manager.sh
#
# Requirements:
# - llama.cpp compiled CLI: ./main
# - Offline environment
# - 'tasks.txt' file with queued tasks (one per line)
# - 'rules.txt' file with rules to enforce
# - 'agent_output/' directory to save results
# - 'timeout.flag' to indicate AI is in timeout

# Source the environment file to get configuration
source "config/environment.txt"

MODEL_PATH="./models/model.gguf"
TASK_FILE="./tasks.txt"
OUTPUT_DIR="./agent_output"
TIMEOUT_FILE="./timeout.flag"
TIMEOUT_DURATION=$((2 * 60 * 60))  # 2 hours in seconds

# Create output dir if missing
mkdir -p "$OUTPUT_DIR"

# Check if AI is in timeout
if [[ -f "$TIMEOUT_FILE" ]]; then
    timeout_start=$(cat "$TIMEOUT_FILE")
    now=$(date +%s)
    elapsed=$(( now - timeout_start ))

    if (( elapsed < TIMEOUT_DURATION )); then
        echo "[INFO] AI is in timeout. Wait $(( (TIMEOUT_DURATION - elapsed)/60 )) minutes."
        exit 0
    else
        echo "[INFO] Timeout expired. Resuming AI."
        rm -f "$TIMEOUT_FILE"
    fi
fi

# Read next task
if [[ ! -s "$TASK_FILE" ]]; then
    echo "[INFO] No pending tasks in $TASK_FILE."
    exit 0
fi

read -r TASK < "$TASK_FILE"

echo "[INFO] Processing task: $TASK"

# Run prompt with PrismQuanta LLM
RESPONSE=$(./main -m "$MODEL_PATH" -p "$TASK" -n 256)

# Function to check rules
function check_rules {
    local text="$1"
    while IFS= read -r rule; do
        if echo "$text" | grep -iq "$rule"; then
            echo "[WARNING] Rule violation detected: '$rule'"
            return 1
        fi
    done < "$RULES_FILE"
    return 0
}

# Enforce rules
if ! check_rules "$RESPONSE"; then
    echo "[INFO] Putting AI into timeout for 2 hours due to rule violation."
    date +%s > "$TIMEOUT_FILE"
    # Optionally log violation
    echo "$(date): Violation detected on task '$TASK'" >> "$OUTPUT_DIR/violations.log"
    exit 1
fi

# Save output with timestamped filename
timestamp=$(date +%F_%T)
output_file="$OUTPUT_DIR/response_$timestamp.txt"
echo "$RESPONSE" > "$output_file"
echo "[INFO] Saved response to $output_file"

# Remove processed task
sed -i '1d' "$TASK_FILE"

exit 0
