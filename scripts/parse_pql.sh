#!/bin/bash

PQL_FILE="tasks.xml"

# List all task IDs and descriptions
list_tasks() {
  xmlstarlet sel -t -m "/tasks/task" -v "@id" -o ": " -v "description" -n "$PQL_FILE"
}

# Extract commands for a specific task ID
get_commands() {
  local task_id="$1"
  xmlstarlet sel -t -m "/tasks/task[@id='$task_id']/commands/command" -v "." -n "$PQL_FILE"
}

# Extract criteria for a specific task ID
get_criteria() {
  local task_id="$1"
  xmlstarlet sel -t -m "/tasks/task[@id='$task_id']/criteria/criterion" -v "." -n "$PQL_FILE"
}
