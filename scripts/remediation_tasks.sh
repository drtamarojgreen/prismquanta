#!/bin/bash
# plan_code_tasks.sh – Multi-stage reflective planner for PrismQuanta

set -euo pipefail
IFS=$'\n\t'

# Source the environment file to get configuration
source "config/environment.txt"

INPUT="memory/requirements.md"
RAW_OUTPUT="memory/task_list_raw.txt"
FINAL_OUTPUT="memory/task_list_final.txt"
REVISED_OUTPUT="memory/task_list_revised.txt"
FLAGGED="memory/flagged_tasks.txt"
ENGINE="./llm_infer.sh"
PROMPT="Break requirements into modular dev tasks with priority labels:"
REVISION_PROMPT="Revise tasks for clarity and rule compliance:"
TMP="memory/task_tmp.txt"

echo "[PLAN] 🧠 Starting reflective planning pipeline..."

gather() {
  echo "[Gather] 📥 Checking input..."
  if [ ! -f "$INPUT" ]; then
    echo "❌ Missing input file: $INPUT"
    exit 1
  fi
  if [ ! -x "$ENGINE" ]; then
    echo "❌ LLM engine script not executable: $ENGINE"
    exit 1
  fi
  echo "[Gather] ✅ Found $INPUT and engine is ready."
}

infer() {
  echo "[Infer] 🔍 Running initial inference..."
  cat "$INPUT" | "$ENGINE" --prompt "$PROMPT" > "$RAW_OUTPUT"
  echo "[Infer] ✅ Raw tasks written to $RAW_OUTPUT"
}

prioritize() {
  echo "[Prioritize] ⚖️ Sorting by priority labels..."
  grep -i 'High Priority' "$RAW_OUTPUT" > "$TMP" || true
  grep -i 'Medium Priority' "$RAW_OUTPUT" >> "$TMP" || true
  grep -i 'Low Priority' "$RAW_OUTPUT" >> "$TMP" || true
  mv "$TMP" "$FINAL_OUTPUT"
  echo "[Prioritize] ✅ Prioritized tasks saved to $FINAL_OUTPUT"
}

schedule() {
  echo "[Schedule] 🕒 Scheduling pass (stubbed for now)..."
  # You can expand this with effort estimates or dates later
}

verify() {
  echo "[Verify] 🧪 Checking for incomplete items..."
  grep -E '^-' "$FINAL_OUTPUT" | grep -v '[a-zA-Z]' && echo "⚠️ Incomplete task found"
  echo "[Verify] ✅ Format check complete."
}

revise() {
  echo "[Revise] 🔁 Scanning for ambiguity and rule violations..."

  # Clear previous flagged tasks to avoid appending duplicates
  > "$FLAGGED"

  # Flag ambiguous verbs or vague scope
  grep -Ei 'handle|optimize|improve|support|refactor|update logic|better UX|efficiency|flexibility' "$FINAL_OUTPUT" > "$FLAGGED" || true

  # Flag potential ethics/bias/rule violations
  grep -Ei 'user profile|demographic data|track user|monitor behavior' "$FINAL_OUTPUT" | grep -vi 'anonymize|privacy' >> "$FLAGGED" || true
  grep -Ei 'delete.*test' "$FINAL_OUTPUT" >> "$FLAGGED" || true

  if [ -s "$FLAGGED" ]; then
    echo "[Revise] ⚠️ Flagged tasks found:"
    cat "$FLAGGED"
    echo "[Revise] 🔄 Re-running LLM for clarification..."
    cat "$FLAGGED" | "$ENGINE" --prompt "$REVISION_PROMPT" > "$REVISED_OUTPUT"
    echo "[Revise] ✅ Revised tasks saved to $REVISED_OUTPUT"
  else
    echo "[Revise] ✅ No flagged items found."
  fi
}

summary() {
  echo "[Summary] 📦 Finalized task list:"
  cat "$FINAL_OUTPUT"
  if [ -s "$REVISED_OUTPUT" ]; then
    echo ""
    echo "[Summary] ✏️ Revised tasks available for review:"
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
