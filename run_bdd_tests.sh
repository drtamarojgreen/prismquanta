#!/bin/bash
# This script is the main entry point for running BDD tests.
# It calls the enhanced test runner which handles parsing .feature files.

# Determine the directory of this script to reliably find the runner.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

# Execute the enhanced BDD test runner, passing along any arguments.
"$SCRIPT_DIR/tests/bdd/enhanced_test_runner.sh" "$@"
