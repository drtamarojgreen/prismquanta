#!/bin/bash
# run_planner.sh - Master control loop for PrismQuanta's thinking cycles

# Source the environment file to get configuration
source "config/environment.txt"

XML_RULES="ruleset.xml"
LOGFILE="memory/run_log.txt"

echo "[RUN] Starting planner loop..." >> "$LOGFILE"

while true; do
    echo "[TASK] Strategizing..." >> "$LOGFILE"
    ./strategize_project.sh

    echo "[TASK] Requirements gathering..." >> "$LOGFILE"
    ./define_requirements.sh

    echo "[TASK] Planning code..." >> "$LOGFILE"
    ./plan_code_tasks.sh

    echo "[WAIT] Cooling off. Sleeping 30m..." >> "$LOGFILE"
    sleep 1800  # Use polling logic if C++ interface is ready
done
