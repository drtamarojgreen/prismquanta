#!/bin/bash
# This script performs code analysis.

# Source utility functions
source "$(dirname "$0")/utils.sh"

# Setup environment
setup_env

log_info "Running code analysis..."

# Language Percentage Analysis
log_info "Language Percentage Analysis:"
total_files=$(find "$PRISM_QUANTA_ROOT" -type f -not -path "$PRISM_QUANTA_ROOT/.git/*" | wc -l)
cpp_files=$(find "$PRISM_QUANTA_ROOT" -name "*.cpp" -o -name "*.h" | wc -l)
sh_files=$(find "$PRISM_QUANTA_ROOT" -name "*.sh" | wc -l)
python_files=$(find "$PRISM_QUANTA_ROOT" -name "*.py" | wc -l)

if [ "$total_files" -ne 0 ]; then
    cpp_percentage=$(echo "scale=2; $cpp_files / $total_files * 100" | bc)
    sh_percentage=$(echo "scale=2; $sh_files / $total_files * 100" | bc)
    python_percentage=$(echo "scale=2; $python_files / $total_files * 100" | bc)
else
    cpp_percentage=0
    sh_percentage=0
    python_percentage=0
fi

echo "C++: $cpp_percentage%"
echo "Shell: $sh_percentage%"
echo "Python: $python_percentage%"

# Test Case Counting
log_info "Test Case Counting:"
test_files=$(find "$PRISM_QUANTA_ROOT/tests" -type f | wc -l)
echo "Number of files in /tests directory: $test_files"
test_cases=$(grep -r -E -i "test|assert" --exclude-dir=".git" "$PRISM_QUANTA_ROOT" | wc -l)
echo "Number of lines containing 'test' or 'assert': $test_cases"

# Key File Size Analysis
log_info "Key File Size Analysis:"
echo "Size of .txt and .xml files:"
find "$PRISM_QUANTA_ROOT" -name "*.txt" -o -name "*.xml" -exec du -h {} +

# Orphaned File Analysis
log_info "Orphaned File Analysis (Beta):"
echo "The following files might be orphaned (not referenced by other files):"
for file in $(find "$PRISM_QUANTA_ROOT" -type f -not -path "$PRISM_QUANTA_ROOT/.git/*" -not -path "$PRISM_QUANTA_ROOT/scripts/code_analysis.sh"); do
    filename=$(basename "$file")
    if ! grep -r -q "$filename" --exclude-dir=".git" --exclude="code_analysis.sh" "$PRISM_QUANTA_ROOT"; then
        echo "$file"
    fi
done

# Project-specific Metrics
log_info "Project-specific Metrics:"
task_count=$(grep -c "<task>" "$TASKS_XML_FILE")
echo "Number of tasks: $task_count"
rule_count=$(grep -c "<rule>" "$RULESET_XML_FILE")
echo "Number of rules: $rule_count"
incident_count=$(wc -l < "$RULES_FILE")
echo "Number of incidents in rules.txt: $incident_count"
prompt_count=$(find "$PROMPT_FILE" -type f | wc -l)
echo "Number of prompts: $prompt_count"
