#!/bin/bash
# memory_review.sh - LLM reflection loop before next task

# Source the environment file to get configuration
source "config/environment.txt"

LOGFILE="memory/review_log.txt"
PQL_FILE="memory/tasks.xml"
OUTPUT_SUMMARY="memory/review_summary.txt"

echo "[REVIEW] Starting memory review at $(date)" >> "$LOGFILE"

step1_recall_task() {
  echo "Step 1: Recalling last PQL task and criteria." >> "$LOGFILE"
  xmlstarlet sel -t -m "/tasks/task[@status='in-progress']" -v "description" -n "$PQL_FILE" >> "$OUTPUT_SUMMARY"
}

step2_check_outputs() {
  echo "Step 2: Examining recent outputs for rule compliance." >> "$LOGFILE"
  tail -n 20 memory/llm_output.log >> "$OUTPUT_SUMMARY"
}

step3_reflect_breaches() {
  echo "Step 3: Checking for past rule breaches." >> "$LOGFILE"
  grep "PUNISH" memory/llm_behavior.log >> "$OUTPUT_SUMMARY"
}

step4_review_logs() {
  echo "Step 4: Reviewing patterns in logs." >> "$LOGFILE"
  tail -n 50 memory/llm_behavior.log >> "$OUTPUT_SUMMARY"
}

step5_summarize() {
  echo "Step 5: Summarizing insights and re-aligning task plan." >> "$LOGFILE"
  echo "Summary: LLM appears to be $(tail -n 10 $OUTPUT_SUMMARY)" >> "$LOGFILE"
}

# Run all steps sequentially
step1_recall_task
step2_check_outputs
step3_reflect_breaches
step4_review_logs
step5_summarize

echo "[REVIEW] Memory review complete at $(date)" >> "$LOGFILE"
