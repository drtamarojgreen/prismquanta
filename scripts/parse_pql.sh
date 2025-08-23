#!/bin/bash
# parse_pql.sh - Parses and validates the PQL task file.

set -euo pipefail
IFS=$'\n\t'

# Source utility functions
source "$(dirname "$0")/utils.sh"

# Setup environment
setup_env

# For compatibility with the script's original variable names
PQL_FILE="$TASKS_XML_FILE"
PQL_SCHEMA="$PQL_SCHEMA_FILE"

# --- Core Logic ---

# List all task IDs and descriptions
list_tasks() {
  xmlstarlet sel -t -m "/tasks/task" -v "@id" -o ": " -v "description" -n "$PQL_FILE"
}

# Extract commands for a specific task ID
get_commands() {
  local task_id="$1"
  if [[ -z "$task_id" ]]; then
    log_error "Task ID is required."
    usage
  fi
  xmlstarlet sel -t -m "/tasks/task[@id='$task_id']/commands/command" -v "." -n "$PQL_FILE"
}

# Extract criteria for a specific task ID
get_criteria() {
  local task_id="$1"
  if [[ -z "$task_id" ]]; then
    log_error "Task ID is required."
    usage
  fi
  xmlstarlet sel -t -m "/tasks/task[@id='$task_id']/criteria/criterion" -v "." -n "$PQL_FILE"
}

# Validate the PQL file against its XSD schema
validate_pql() {
  local file_to_validate="$1"
  if [[ -z "$file_to_validate" ]]; then
    log_error "Validate command requires a filename."
    usage
  fi
  if [[ ! -f "$file_to_validate" ]]; then
      log_error "File to validate not found at '$file_to_validate'"
  fi
  if [[ ! -f "$PQL_SCHEMA" ]]; then
    log_error "PQL schema file not found at '$PQL_SCHEMA'"
  fi
  log_info "Validating $file_to_validate against $PQL_SCHEMA..."
  # Use xmlstarlet to validate. The 'val' command returns non-zero on failure.
  if xmlstarlet val --err --xsd "$PQL_SCHEMA" "$file_to_validate"; then
    log_info "$file_to_validate is valid."
  else
    # We exit with 1 so that scripts calling this can detect failure.
    # log_error exits the whole shell, which might be too abrupt.
    echo "[ERROR] $file_to_validate is invalid. Please check against the schema." >&2
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
  echo "  list_by_status <status> Lists all task IDs and descriptions with a given status"
  echo "  commands <id>   Extracts commands for a specific task ID"
  echo "  criteria <id>   Extracts criteria for a specific task ID"
}

list_by_status() {
    local status="$1"
    if [[ -z "$status" ]]; then
        log_error "Status is required."
        usage
    fi
    xmlstarlet sel -t -m "/tasks/task[@status='$status']" -v "@id" -o ": " -v "description" -n "$PQL_FILE"
}

main() {
  check_deps "xmlstarlet"

  if [[ ! -f "$PQL_FILE" ]]; then
    log_error "PQL file not found at '$PQL_FILE'"
  fi

  local command="$1"
  shift

  case "$command" in
    list) list_tasks ;;
    list_by_status) list_by_status "$@" ;;
    commands) get_commands "$@" ;;
    criteria) get_criteria "$@" ;;
    validate) validate_pql "$@" ;;
    ""|--help|-h) usage ;;
    *)
      log_error "Unknown command '$command'"
      usage
      ;;
  esac
}

# Only run main if the script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
