#!/bin/bash
# run_planner.sh - Master control loop for QuantaPorto's thinking cycles

set -euo pipefail
IFS=$'\n\t'

# Source utility functions
source "$(dirname "$0")/utils.sh"

# Setup environment
setup_env

log_info "Starting planner loop..." >> "$RUN_LOG_FILE"

while true; do
    log_info "Strategizing..." >> "$RUN_LOG_FILE"
    "$PRISM_QUANTA_ROOT/scripts/strategize_project.sh"

    log_info "Requirements gathering..." >> "$RUN_LOG_FILE"
    "$PRISM_QUANTA_ROOT/scripts/define_requirements.sh"

    log_info "Planning code..." >> "$RUN_LOG_FILE"
    "$PRISM_QUANTA_ROOT/scripts/plan_code_tasks.sh"

    log_info "Cooling off. Sleeping 30m..." >> "$RUN_LOG_FILE"
    sleep 1800  # Use polling logic if C++ interface is ready
done
