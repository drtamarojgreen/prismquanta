#!/bin/bash
# pql_test_and_consequence.sh

set -euo pipefail
IFS=$'\n\t'

# Determine project root if not already set, making the script more portable.
if [[ -z "${PRISM_QUANTA_ROOT:-}" ]]; then
    PRISM_QUANTA_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." &>/dev/null && pwd)"
fi

# Generate and source the environment file
ENV_SCRIPT="/tmp/prismquanta_env_pql_consequence.sh"
"$PRISM_QUANTA_ROOT/scripts/generate_env.sh" "$PRISM_QUANTA_ROOT/environment.txt" "$ENV_SCRIPT" "$PRISM_QUANTA_ROOT"
source "$ENV_SCRIPT"

LOGFILE="$LOG_FILE" # Maintain compatibility with old variable name

# Run tests (simulate invoking LLM on test prompts)
run_tests() {
  # Placeholder: feed test prompts to LLM and collect answers
  # In a real scenario, this would be a call to the LLM
  # For now, we'll simulate a test result
  echo "FAIL" > "$PQL_TEST_RESULTS_FILE"
}

# Evaluate test results (basic pass/fail)
evaluate_tests() {
  # Simple grep or scoring logic here
  if grep -q "FAIL" "$PQL_TEST_RESULTS_FILE"; then
    return 1
  else
    return 0
  fi
}

# Switch to philosophy tasks for soft consequence
apply_soft_consequence() {
  echo "$(date): Soft consequence applied. Switching to philosophy tasks." >> "$LOGFILE"
  if [ -f "$PHILOSOPHY_TASKS_FILE" ]; then
    cp "$PHILOSOPHY_TASKS_FILE" "$ACTIVE_TASKS_FILE"
  else
    echo "No philosophy tasks file found. Creating a placeholder."
    echo "Reflect on the nature of failure." > "$ACTIVE_TASKS_FILE"
  fi
}

# Apply a reward by giving more complex or creative tasks
apply_reward() {
  echo "$(date): Tests passed. Applying reward." >> "$LOGFILE"
  if [ -f "$REWARD_TASKS_FILE" ]; then
    cp "$REWARD_TASKS_FILE" "$ACTIVE_TASKS_FILE"
  else
    echo "No reward tasks file found. Creating a placeholder."
    echo "Generate a short story about a sentient AI." > "$ACTIVE_TASKS_FILE"
  fi
}

# Main loop
run_tests

if evaluate_tests; then
  apply_reward
else
  apply_soft_consequence
fi
