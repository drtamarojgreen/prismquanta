#!/bin/bash

# Native Test Runner
# A simple, dependency-free test runner for shell scripts.

# Determine and export the project root directory. This is crucial for ensuring
# that step definitions can find scripts, logs, and config files.
if [[ -z "${PRISM_QUANTA_ROOT:-}" ]]; then
    # The runner is in tests/bdd, so the project root is two levels up.
    PRISM_QUANTA_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." &>/dev/null && pwd)"
    export PRISM_QUANTA_ROOT
fi

# --- Configuration ---
# The pattern to identify test files.
TEST_FILE_PATTERN="_test.sh"
# The prefix to identify test functions within a test file.
TEST_FUNCTION_PREFIX="test_"

# --- State ---
PASSED_COUNT=0
FAILED_COUNT=0
TOTAL_COUNT=0

# --- Utility Functions ---

# Find the absolute path to the step_definitions.sh file
# This assumes the runner is in tests/bdd/ and steps are in tests/bdd/
# Adjust if the directory structure changes.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
STEP_DEFINITIONS_PATH="${SCRIPT_DIR}/step_definitions.sh"

if [[ ! -f "$STEP_DEFINITIONS_PATH" ]]; then
    echo "FATAL: Could not find step_definitions.sh at $STEP_DEFINITIONS_PATH"
    exit 1
fi

# --- Core Runner Logic ---

echo "Starting Native Test Runner..."
echo "Looking for test files ending with '${TEST_FILE_PATTERN}'"
echo "========================================================================"

# Check if file arguments are provided
if [ "$#" -eq 0 ]; then
    echo "Usage: $0 <path/to/test_file.sh> [another_test_file.sh ...]"
    exit 1
fi

for test_file in "$@"; do
    if [[ ! -f "$test_file" ]]; then
        echo "Warning: Test file not found: $test_file. Skipping."
        continue
    fi

    echo "RUNNING: $test_file"

    # Get a list of test functions from the file
    # We use sed to extract the function name without the '()'
    test_functions=$(grep -E "^${TEST_FUNCTION_PREFIX}[a-zA-Z0-9_]*\s*\(\)" "$test_file" | sed 's/().*//')

    if [[ -z "$test_functions" ]]; then
        echo "  -> No test functions found. Skipping."
        continue
    fi

    # Source the step definitions and the test file for each run
    # Sourcing inside the loop allows tests to have file-scoped helper functions
    # without polluting other test files.
    source "$STEP_DEFINITIONS_PATH"
    source "$test_file"

    for func_name in $test_functions; do
        TOTAL_COUNT=$((TOTAL_COUNT + 1))
        echo -n "  - ${func_name}... "

        # Run the test function in a subshell to isolate it
        # This prevents a failing test from exiting the entire runner
        ( "$func_name" )
        result=$?

        if [ $result -eq 0 ]; then
            echo -e "\e[32mPASS\e[0m" # Green PASS
            PASSED_COUNT=$((PASSED_COUNT + 1))
        else
            echo -e "\e[31mFAIL\e[0m" # Red FAIL
            FAILED_COUNT=$((FAILED_COUNT + 1))
        fi
    done
done

# --- Summary ---

echo "========================================================================"
echo "TEST SUMMARY"
echo "Total Tests: $TOTAL_COUNT"
echo -e "Passed: \e[32m$PASSED_COUNT\e[0m"
echo -e "Failed: \e[31m$FAILED_COUNT\e[0m"
echo "========================================================================"

# Exit with a status code indicating success or failure
if [ $FAILED_COUNT -eq 0 ]; then
    exit 0
else
    exit 1
fi
