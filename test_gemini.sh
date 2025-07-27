#!/bin/bash
# test_gemini.sh - A non-destructive demonstration script for PrismQuanta.
# This script ONLY runs existing components and shows how they APPEND to log files.
# It does not create, overwrite, or delete any files.

set -euo pipefail
IFS=$'\n\t'

# --- Setup ---
export PRISM_QUANTA_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"

# Colors for output
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# --- Helper Functions ---
print_header() {
    echo -e "\n${BLUE}============================================================${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}============================================================${NC}"
}

# --- Main Execution ---
main() {
    print_header "Running Non-Destructive Demonstration (Append-Only)"

    echo "This script will execute the main components and show how they"
    echo "append to log files without deleting or overwriting other data."
    echo
    echo "NOTE: This demo requires a mock send_prompt.sh and pre-populated"
    echo "task files to run correctly. It only verifies the logging."
    echo

    # --- Demonstrate Task Manager Logging ---
    print_header "1. Running Enhanced Task Manager"
    echo "Assuming 'tasks.txt' contains a task. Running the manager..."
    # We run it but ignore the exit code because it might fail if the task
    # is non-compliant, which is part of the demonstration.
    "$PRISM_QUANTA_ROOT/scripts/enhanced_task_manager.sh" || true

    echo
    echo "Verifying by showing the last 10 lines of the ethics log:"
    echo "--------------------------------------------------------"
    tail -n 10 "$PRISM_QUANTA_ROOT/logs/ethics_violations.log"
    echo "--------------------------------------------------------"
    echo "New entries should be appended above."

    # --- Demonstrate PQL Test & Reward Logging ---
    print_header "2. Running PQL Test & Reward System"
    echo "Running the test and reward script..."
    "$PRISM_QUANTA_ROOT/scripts/pql_test_and_reward.sh" || true

    echo
    echo "Verifying by showing the last 10 lines of the run log:"
    echo "--------------------------------------------------------"
    tail -n 10 "$PRISM_QUANTA_ROOT/logs/run_log.txt"
    echo "--------------------------------------------------------"
    echo "A new 'Test and Reward Cycle' entry should be appended above."

    print_header "DEMONSTRATION COMPLETE"
    echo "The demonstration has finished. All operations were append-only to logs."
}

main