#!/bin/bash

# BDD Test Runner

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Counters
PASS_COUNT=0
FAIL_COUNT=0
PENDING_COUNT=0

# Source the step definitions
if [ -f "step_definitions.sh" ]; then
    source "step_definitions.sh"
else
    echo -e "${RED}Error: step_definitions.sh not found!${NC}"
    exit 1
fi

# --- Test Execution Functions ---

# Function to execute a single step
execute_step() {
    local step_keyword=$1
    local step_action=$2

    echo -e "  ${YELLOW}${step_keyword}${NC} ${step_action}"

    # Find the corresponding function in step_definitions.sh
    local function_name=$(echo "$step_action" | sed 's/ /_/g' | tr -d '[:punct:]')

    if type "$function_name" &>/dev/null; then
        if "$function_name" "$@"; then
            echo -e "    ${GREEN}✔ Passed${NC}"
            ((PASS_COUNT++))
        else
            echo -e "    ${RED}✖ Failed${NC}"
            ((FAIL_COUNT++))
        fi
    else
        echo -e "    ${YELLOW}… Pending${NC}"
        ((PENDING_COUNT++))
    fi
}

# --- Main Test Runner Logic ---

# Find and run all feature files
for feature_file in features/*.feature; do
    echo "Feature: $(grep "Feature:" "$feature_file" | cut -d: -f2-)"

    # Read the feature file line by line
    while IFS= read -r line; do
        # Skip empty lines and comments
        [[ -z "$line" || "$line" =~ ^# ]] && continue

        # Identify Scenario
        if [[ "$line" =~ ^\s*Scenario: ]]; then
            echo -e "\n  Scenario: $(echo "$line" | sed 's/^\s*Scenario:\s*//')"
            continue
        fi

        # Identify and execute steps
        if [[ "$line" =~ ^\s*(Given|When|Then|And|But) ]]; then
            keyword=$(echo "$line" | awk '{print $1}')
            action=$(echo "$line" | sed -E 's/^\s*(Given|When|Then|And|But)\s*//')
            # Extract arguments from the action
            args=$(echo "$action" | grep -o '".*"' | sed 's/"//g')
            execute_step "$keyword" "$action" $args
        fi
    done < "$feature_file"
done

# --- Summary ---
echo -e "\n--- Test Summary ---"
echo -e "${GREEN}Passed: $PASS_COUNT${NC}"
echo -e "${RED}Failed: $FAIL_COUNT${NC}"
echo -e "${YELLOW}Pending: $PENDING_COUNT${NC}"

# Exit with a non-zero status code if any tests failed
if [ "$FAIL_COUNT" -gt 0 ]; then
    exit 1
fi
