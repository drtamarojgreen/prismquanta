#!/bin/bash
# parse_pql.sh - Parses and validates the PQL task file.

# --- Configuration ---
PQL_FILE="tasks.xml"
PQL_SCHEMA="pql.xsd"

# --- Helper Functions ---

# Function to check for required dependencies
check_deps() {
  if ! command -v xmlstarlet &> /dev/null; then
    echo "Error: xmlstarlet is not installed. Please install it to continue." >&2
    exit 1
  fi
}

# --- Core Logic ---

# List all task IDs and descriptions
list_tasks() {
  xmlstarlet sel -t -m "/tasks/task" -v "@id" -o ": " -v "description" -n "$PQL_FILE"
}

# Extract commands for a specific task ID
get_commands() {
  local task_id="$1"
  if [[ -z "$task_id" ]]; then
    echo "Error: Task ID is required." >&2
    usage
    exit 1
  fi
  xmlstarlet sel -t -m "/tasks/task[@id='$task_id']/commands/command" -v "." -n "$PQL_FILE"
}

# Extract criteria for a specific task ID
get_criteria() {
  local task_id="$1"
  if [[ -z "$task_id" ]]; then
    echo "Error: Task ID is required." >&2
    usage
    exit 1
  fi
  xmlstarlet sel -t -m "/tasks/task[@id='$task_id']/criteria/criterion" -v "." -n "$PQL_FILE"
}

# Validate the PQL file against its XSD schema
validate_pql() {
  if [[ ! -f "$PQL_SCHEMA" ]]; then
    echo "Error: PQL schema file not found at '$PQL_SCHEMA'" >&2
    exit 1
  fi
  echo "Validating $PQL_FILE against $PQL_SCHEMA..."
  # Use xmlstarlet to validate. The 'val' command returns non-zero on failure.
  if xmlstarlet val --err --xsd "$PQL_SCHEMA" "$PQL_FILE"; then
    echo "$PQL_FILE is valid."
  else
    echo "Error: $PQL_FILE is invalid. Please check against the schema." >&2
    exit 1
  fi
}

# --- Main Execution ---

usage() {
  echo "Usage: $0 <command> [task_id]"
  echo
  echo "Commands:"
  echo "  validate        Validates $PQL_FILE against $PQL_SCHEMA"
  echo "  list            Lists all task IDs and descriptions"
  echo "  commands <id>   Extracts commands for a specific task ID"
  echo "  criteria <id>   Extracts criteria for a specific task ID"
}

main() {
  check_deps

  if [[ ! -f "$PQL_FILE" ]]; then
    echo "Error: PQL file not found at '$PQL_FILE'" >&2
    exit 1
  fi

  local command="$1"
  shift

  case "$command" in
    list) list_tasks ;;
    commands) get_commands "$@" ;;
    criteria) get_criteria "$@" ;;
    validate) validate_pql ;;
    ""|--help|-h) usage ;;
    *)
      echo "Error: Unknown command '$command'" >&2
      usage
      exit 1
      ;;
  esac
}

# Only run main if the script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
