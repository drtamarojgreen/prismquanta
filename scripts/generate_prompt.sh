#!/bin/bash
# generate_prompt.sh - Assembles a structured LLM prompt from a PQL task.

set -euo pipefail
IFS=$'\n\t'

# Determine project root if not already set, making the script more portable.
if [[ -z "${PRISM_QUANTA_ROOT:-}" ]]; then
    PRISM_QUANTA_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." &>/dev/null && pwd)"
fi

# Generate and source the environment file
ENV_SCRIPT="/tmp/prismquanta_env_genprompt.sh"
"$PRISM_QUANTA_ROOT/scripts/generate_env.sh" "$PRISM_QUANTA_ROOT/environment.txt" "$ENV_SCRIPT" "$PRISM_QUANTA_ROOT"
source "$ENV_SCRIPT"

# --- Helper Functions ---

# Function to check for required dependencies
check_deps() {
  if ! command -v xmlstarlet &> /dev/null; then
    echo "Error: xmlstarlet is not installed. Please install it to continue." >&2
    exit 1
  fi
}

usage() {
  echo "Usage: $0 <task_id>"
  echo "  Generates a structured prompt for the given task ID."
  echo "  Expects document content to be piped via stdin."
  exit 1
}

# --- Main Execution ---
main() {
  check_deps

  local task_id="$1"
  if [[ -z "$task_id" ]]; then
    echo "Error: Task ID is required." >&2
    usage
  fi

  if [[ ! -f "$PQL_FILE" ]]; then
    echo "Error: PQL file not found at '$PQL_FILE'" >&2
    exit 1
  fi

  # Check if a task with the given ID exists
  local task_exists
  task_exists=$(xmlstarlet sel -t -v "count(/tasks/task[@id='$task_id'])" "$PQL_FILE")
  if [[ "$task_exists" -eq 0 ]]; then
    echo "Error: Task ID '$task_id' not found in $PQL_FILE." >&2
    exit 1
  fi

  # Read document content from stdin
  local doc_content
  if ! tty -s; then
    doc_content=$(cat)
  else
    doc_content="" # Handle case where nothing is piped
  fi

  # Extract data from PQL using xmlstarlet
  local task_description
  task_description=$(xmlstarlet sel -t -v "/tasks/task[@id='$task_id']/description" "$PQL_FILE")
  
  local commands
  commands=$(xmlstarlet sel -t -m "/tasks/task[@id='$task_id']/commands/command" -v . -n "$PQL_FILE" | awk '{print NR". "$0}')

  local criteria
  criteria=$(xmlstarlet sel -t -m "/tasks/task[@id='$task_id']/criteria/criterion" -v . -n "$PQL_FILE" | sed 's/^/- /')

  # Assemble the prompt using a HEREDOC for clarity
  cat << PROMPT
[SYSTEM]
You are a highly capable AI assistant. Your task is to follow a set of commands and adhere to specific criteria to produce a precise output. Do not deviate from the instructions.

[TASK]
$task_description

[COMMANDS]
$commands

[CRITERIA]
$criteria

[DOCUMENT CONTENT]
$doc_content

[RESPONSE]
PROMPT
}

# Run main
main "$@"