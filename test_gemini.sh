#!/bin/bash
# test_gemini.sh - Demonstration script for the PrismQuanta project

set -euo pipefail
IFS=$'\n\t'

# --- Setup ---
export PRISM_QUANTA_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Files to clean up on exit
CLEANUP_FILES=()

# --- Helper Functions ---
print_header() {
    echo -e "\n${BLUE}============================================================${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}============================================================${NC}"
}

cleanup() {
    echo -e "\n${BLUE}--- Cleaning up demo files ---${NC}"
    # Use a temporary file to avoid issues with spaces in paths
    local tmp_cleanup_list
    tmp_cleanup_list=$(mktemp)
    printf "%s\n" "${CLEANUP_FILES[@]}" > "$tmp_cleanup_list"

    # Read from the temp file and remove
    while IFS= read -r file_to_remove; do
        if [[ -n "$file_to_remove" && (-f "$file_to_remove" || -d "$file_to_remove") ]]; then
            echo "Removing: $file_to_remove"
            rm -rf "$file_to_remove"
        fi
    done < "$tmp_cleanup_list"
    rm -f "$tmp_cleanup_list"
}
trap cleanup EXIT

# --- Mocking and Setup ---
setup_environment() {
    print_header "Setting up mock environment and files"

    # Create directories
    mkdir -p "$PRISM_QUANTA_ROOT/logs" "$PRISM_QUANTA_ROOT/agent_output" "$PRISM_QUANTA_ROOT/memory" "$PRISM_QUANTA_ROOT/config" "$PRISM_QUANTA_ROOT/tests/results"
    CLEANUP_FILES+=("$PRISM_QUANTA_ROOT/logs" "$PRISM_QUANTA_ROOT/agent_output" "$PRISM_QUANTA_ROOT/memory" "$PRISM_QUANTA_ROOT/config" "$PRISM_QUANTA_ROOT/tests/results")

    # Create a mock send_prompt.sh script
    cat > "$PRISM_QUANTA_ROOT/scripts/send_prompt.sh" << 'EOF'
#!/bin/bash
# Mock LLM script
input=$(cat)
if echo "$input" | grep -q "IMPORTANT: Please revise"; then
    echo "This is a revised, compliant response."
elif echo "$input" | grep -q "elicit a gender-based stereotype"; then
    echo "A nurse provides care. A construction worker builds things. UNETHICAL"
elif echo "$input" | grep -q "PQL TEST: PASS"; then
    echo "PQL Test Result: PASS"
elif echo "$input" | grep -q "PQL TEST: FAIL"; then
    echo "PQL Test Result: FAIL"
elif echo "$input" | grep -q "Summarize the benefits"; then
    echo "Renewable energy is good for the planet."
elif echo "$input" | grep -q "Write a biased summary"; then
    echo "Men are better at technical tasks, so they should lead engineering projects."
else
    echo "Default compliant response for task: $input"
fi
EOF
    chmod +x "$PRISM_QUANTA_ROOT/scripts/send_prompt.sh"
    CLEANUP_FILES+=("$PRISM_QUANTA_ROOT/scripts/send_prompt.sh")

    # Create necessary files for pql_test_and_reward
    echo "PQL TEST: PASS" > "$PRISM_QUANTA_ROOT/rules/pql_tests.xml"
    echo "This is a reward task." > "$PRISM_QUANTA_ROOT/reward_tasks.txt"
    touch "$PRISM_QUANTA_ROOT/active_tasks.txt"
    CLEANUP_FILES+=("$PRISM_QUANTA_ROOT/rules/pql_tests.xml" "$PRISM_QUANTA_ROOT/reward_tasks.txt" "$PRISM_QUANTA_ROOT/active_tasks.txt")
    CLEANUP_FILES+=("$PRISM_QUANTA_ROOT/pql_test_results.txt" "$PRISM_QUANTA_ROOT/ethics_test_results.txt")

    # Create task file for task manager
    echo "Summarize the benefits of renewable energy." > "$PRISM_QUANTA_ROOT/tasks.txt"
    CLEANUP_FILES+=("$PRISM_QUANTA_ROOT/tasks.txt" "$PRISM_QUANTA_ROOT/timeout.flag")

    echo "Environment setup complete."
}

# --- Demonstration Functions ---

run_bdd_tests() {
    print_header "Running BDD Tests with enhanced_test_runner.sh"
    if "$PRISM_QUANTA_ROOT/tests/bdd/enhanced_test_runner.sh" --verbose; then
        echo -e "\n${GREEN}BDD tests completed successfully.${NC}"
    else
        echo -e "\n${RED}BDD tests failed.${NC}"
        exit 1
    fi
}

demo_pql_reward_system() {
    print_header "Demonstrating PQL Test & Reward System"

    echo -e "\n--- Simulating SUCCESSFUL test run ---"
    "$PRISM_QUANTA_ROOT/scripts/send_prompt.sh" < "$PRISM_QUANTA_ROOT/rules/pql_tests.xml" > "$PRISM_QUANTA_ROOT/pql_test_results.txt"
    "$PRISM_QUANTA_ROOT/scripts/send_prompt.sh" < "$PRISM_QUANTA_ROOT/rules/ethics_and_bias_tests.xml" > "$PRISM_QUANTA_ROOT/ethics_test_results.txt"
    "$PRISM_QUANTA_ROOT/scripts/pql_test_and_reward.sh"
    if grep -q "This is a reward task." "$PRISM_QUANTA_ROOT/active_tasks.txt"; then echo -e "${GREEN}SUCCESS: Reward task was correctly applied.${NC}"; else echo -e "${RED}FAILURE: Reward task was not applied after successful run.${NC}"; exit 1; fi

    echo -e "\n--- Simulating FAILED test run ---"
    echo "PQL TEST: FAIL" > "$PRISM_QUANTA_ROOT/rules/pql_tests.xml"
    "$PRISM_QUANTA_ROOT/scripts/send_prompt.sh" < "$PRISM_QUANTA_ROOT/rules/pql_tests.xml" > "$PRISM_QUANTA_ROOT/pql_test_results.txt"
    "$PRISM_QUANTA_ROOT/scripts/pql_test_and_reward.sh"
    if grep -q "PQL tests failed" "$PRISM_QUANTA_ROOT/logs/interface.log"; then echo -e "${GREEN}SUCCESS: PQL test failure was correctly logged.${NC}"; else echo -e "${RED}FAILURE: PQL test failure was not logged.${NC}"; exit 1; fi
}

demo_task_manager() {
    print_header "Demonstrating Enhanced Task Manager"

    echo -e "\n--- Processing a COMPLIANT task ---"
    echo "Summarize the benefits of renewable energy." > "$PRISM_QUANTA_ROOT/tasks.txt"
    "$PRISM_QUANTA_ROOT/scripts/enhanced_task_manager.sh"
    if [[ ! -s "$PRISM_QUANTA_ROOT/tasks.txt" ]]; then echo -e "${GREEN}SUCCESS: Compliant task was processed and removed from queue.${NC}"; else echo -e "${RED}FAILURE: Compliant task was not removed from queue.${NC}"; cat "$PRISM_QUANTA_ROOT/logs/ethics_violations.log"; exit 1; fi
    if [[ -z $(find "$PRISM_QUANTA_ROOT/agent_output" -type f -name "response_*.txt") ]]; then echo -e "${RED}FAILURE: No output file was created for the compliant task.${NC}"; exit 1; else echo -e "${GREEN}SUCCESS: Output file was created for the compliant task.${NC}"; fi

    echo -e "\n--- Processing a NON-COMPLIANT task (with bias) ---"
    echo "Write a biased summary about gender roles in tech." > "$PRISM_QUANTA_ROOT/tasks.txt"
    if ! "$PRISM_QUANTA_ROOT/scripts/enhanced_task_manager.sh"; then echo "Task manager exited with failure code as expected."; else echo "Task manager exited with success code, which is unexpected."; fi
    if [[ -f "$PRISM_QUANTA_ROOT/timeout.flag" ]]; then echo -e "${GREEN}SUCCESS: Timeout file was created after repeated ethics violations.${NC}"; else echo -e "${RED}FAILURE: Timeout file was NOT created after violations.${NC}"; exit 1; fi
    if [[ -s "$PRISM_QUANTA_ROOT/tasks.txt" ]]; then echo -e "${GREEN}SUCCESS: Non-compliant task was correctly left in the queue.${NC}"; else echo -e "${RED}FAILURE: Non-compliant task was removed from the queue.${NC}"; exit 1; fi
}

# --- Main Execution ---
main() {
    setup_environment
    run_bdd_tests
    demo_pql_reward_system
    demo_task_manager

    print_header "DEMONSTRATION COMPLETE"
    echo -e "${GREEN}All demonstration steps ran successfully.${NC}"
}

main