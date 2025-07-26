#!/bin/bash
# run_planner.sh - Master control loop for PrismQuanta's thinking cycles

# Source the environment file to get configuration
source "config/environment.txt"

echo "[RUN] Starting planner loop..." >> "$RUN_LOG_FILE"

while true; do
    echo "[TASK] Strategizing..." >> "$RUN_LOG_FILE"
    ./strategize_project.sh

    echo "[TASK] Requirements gathering..." >> "$RUN_LOG_FILE"
    ./define_requirements.sh

    echo "[TASK] Planning code..." >> "$RUN_LOG_FILE"
    ./plan_code_tasks.sh

    echo "[WAIT] Cooling off. Sleeping 30m..." >> "$RUN_LOG_FILE"
    sleep 1800  # Use polling logic if C++ interface is ready
done
