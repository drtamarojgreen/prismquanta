#!/bin/bash

# A simple test runner script

echo "Running tests..."

# Test if the memory directory exists
if [ -d "memory" ]; then
  echo "PASS: memory directory exists."
else
  echo "FAIL: memory directory does not exist."
  exit 1
fi
