#!/bin/bash
# plan_code_tasks.sh – Multi-stage reflective planner for PrismQuanta

set -euo pipefail
IFS=$'\n\t'

# Determine project root if not already set, making the script more portable.
if [[ -z "${PRISM_QUANTA_ROOT:-}" ]]; then
    PRISM_QUANTA_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." &>/dev/null && pwd)"
fi

# Generate and source the environment file
ENV_SCRIPT="/tmp/prismquanta_env_plan_code.sh"
"$PRISM_QUANTA_ROOT/scripts/generate_env.sh" "$PRISM_QUANTA_ROOT/environment.txt" "$ENV_SCRIPT" "$PRISM_QUANTA_ROOT"
source "$ENV_SCRIPT"

# Map environment variables to the script's expected variable names
INPUT="$REQUIREMENTS_FILE"
ENGINE="$LLM_INFER_SCRIPT"
RAW_OUTPUT="$TASK_LIST_RAW_FILE"
TMP="$TASK_TMP_FILE"
FINAL_OUTPUT="$TASK_LIST_FINAL_FILE"
FLAGGED="$FLAGGED_TASKS_FILE"
REVISED_OUTPUT="$TASK_LIST_REVISED_FILE"

PROMPT="Break requirements into modular dev tasks with priority labels:"
REVISION_PROMPT="Revise tasks for clarity and rule compliance:"

echo "[PLAN] Starting reflective planning pipeline..."

gather() {
  echo "[Gather] Checking input..."
  if [ ! -f "$INPUT" ]; then
    echo "Missing input file: $INPUT"
    exit 1
  fi
  if [ ! -x "$ENGINE" ]; then
    echo "LLM engine script not executable: $ENGINE"
    exit 1
  fi
  echo "[Gather] Found $INPUT and engine is ready."
}

infer() {
  echo "[Infer] Running initial inference..."
  cat "$INPUT" | "$ENGINE" --prompt "$PROMPT" > "$RAW_OUTPUT"
  echo "[Infer] Raw tasks written to $RAW_OUTPUT"
}

prioritize() {
  echo "[Prioritize] Sorting by priority labels..."
  grep -i 'High Priority' "$RAW_OUTPUT" > "$TMP" || true
  grep -i 'Medium Priority' "$RAW_OUTPUT" >> "$TMP" || true
  grep -i 'Low Priority' "$RAW_OUTPUT" >> "$TMP" || true
  mv "$TMP" "$FINAL_OUTPUT"
  echo "[Prioritize] Prioritized tasks saved to $FINAL_OUTPUT"
}

schedule() {
  echo "[Schedule] Scheduling pass (stubbed for now)..."
  # You can expand this with effort estimates or dates later
}

verify() {
  echo "[Verify] Checking for incomplete items..."
  grep -E '^-' "$FINAL_OUTPUT" | grep -v '[a-zA-Z]' && echo "Incomplete task found"
  echo "[Verify] Format check complete."
}

revise() {
  echo "[Revise] Scanning for ambiguity and rule violations..."

  # Flag ambiguous verbs or vague scope
  grep -Ei 'handle|optimize|improve|support|refactor|update logic|better UX|efficiency|flexibility' "$FINAL_OUTPUT" > "$FLAGGED" || true

  # Flag rule violations (example: deletion of test files)
  grep -Ei 'delete.*test' "$FINAL_OUTPUT" >> "$FLAGGED" || true

  if [ -s "$FLAGGED" ]; then
    echo "[Revise] Flagged tasks found:"
    cat "$FLAGGED"
    echo "[Revise] Re-running LLM for clarification..."
    cat "$FLAGGED" | "$ENGINE" --prompt "$REVISION_PROMPT" > "$REVISED_OUTPUT"
    echo "[Revise] Revised tasks saved to $REVISED_OUTPUT"
  else
    echo "[Revise] No flagged items found."
  fi
}

summary() {
  echo "[Summary] Finalized task list:"
  cat "$FINAL_OUTPUT"
  if [ -s "$REVISED_OUTPUT" ]; then
    echo ""
    echo "[Summary] Revised tasks available for review:"
    cat "$REVISED_OUTPUT"
  fi
}

# Pipeline execution
gather
infer
prioritize
schedule
verify
revise
summary
