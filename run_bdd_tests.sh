#!/bin/bash
# This script is the main entry point for running BDD tests.
# It now uses the simple, native test runner.

# Determine the directory of this script to reliably find the test files.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
TEST_DIR="$SCRIPT_DIR/tests/bdd"

# Find all native test files (ending in _test.sh)
TEST_FILES=$(find "$TEST_DIR/features" -name "*_test.sh")

if [ -z "$TEST_FILES" ]; then
    echo "No native test files (*_test.sh) found in $TEST_DIR/features."
    exit 0
fi

# Execute the native test runner with all found test files.
"$TEST_DIR/native_test_runner.sh" $TEST_FILES
