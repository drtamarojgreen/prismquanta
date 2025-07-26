#!/bin/bash
# This script performs code analysis.
echo "Running code analysis..."

# Language Percentage Analysis
echo "Language Percentage Analysis:"
total_files=$(find . -type f -not -path "./.git/*" | wc -l)
cpp_files=$(find . -name "*.cpp" -o -name "*.h" | wc -l)
sh_files=$(find . -name "*.sh" | wc -l)
python_files=$(find . -name "*.py" | wc -l)

cpp_percentage=$(echo "scale=2; $cpp_files / $total_files * 100" | bc)
sh_percentage=$(echo "scale=2; $sh_files / $total_files * 100" | bc)
python_percentage=$(echo "scale=2; $python_files / $total_files * 100" | bc)

echo "C++: $cpp_percentage%"
echo "Shell: $sh_percentage%"
echo "Python: $python_percentage%"

# Test Case Counting
echo -e "\nTest Case Counting:"
test_files=$(find ./tests -type f | wc -l)
echo "Number of files in /tests directory: $test_files"
test_cases=$(grep -r -E -i "test|assert" --exclude-dir=".git" . | wc -l)
echo "Number of lines containing 'test' or 'assert': $test_cases"

# Key File Size Analysis
echo -e "\nKey File Size Analysis:"
echo "Size of .txt and .xml files:"
find . -name "*.txt" -o -name "*.xml" -exec du -h {} +

# Orphaned File Analysis
echo -e "\nOrphaned File Analysis (Beta):"
echo "The following files might be orphaned (not referenced by other files):"
for file in $(find . -type f -not -path "./.git/*" -not -path "./scripts/code_analysis.sh"); do
    filename=$(basename "$file")
    if ! grep -r -q "$filename" --exclude-dir=".git" --exclude="code_analysis.sh" .; then
        echo "$file"
    fi
done

# Source the environment file to get configuration
source "config/environment.txt"

# Project-specific Metrics
echo -e "\nProject-specific Metrics:"
task_count=$(grep -c "<task>" "$TASKS_XML_FILE")
echo "Number of tasks: $task_count"
rule_count=$(grep -c "<rule>" "$RULESET_XML_FILE")
echo "Number of rules: $rule_count"
incident_count=$(wc -l < "$RULES_FILE")
echo "Number of incidents in rules.txt: $incident_count"
prompt_count=$(find "$PROMPT_FILE" -type f | wc -l)
echo "Number of prompts: $prompt_count"
