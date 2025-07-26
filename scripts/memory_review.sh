#!/bin/bash
# memory_review.sh - LLM reflection loop before next task

# Source the environment file to get configuration
source "config/environment.txt"

echo "[REVIEW] Starting memory review at $(date)" >> "$REVIEW_LOG_FILE"

step1_recall_task() {
  echo "Step 1: Recalling last PQL task and criteria." >> "$REVIEW_LOG_FILE"
  xmlstarlet sel -t -m "/tasks/task[@status='in-progress']" -v "description" -n "$TASKS_XML_FILE" >> "$REVIEW_SUMMARY_FILE"
}

step2_check_outputs() {
  echo "Step 2: Examining recent outputs for rule compliance." >> "$REVIEW_LOG_FILE"
  tail -n 20 "$LLM_OUTPUT_LOG" >> "$REVIEW_SUMMARY_FILE"
}

step3_reflect_breaches() {
  echo "Step 3: Checking for past rule breaches." >> "$REVIEW_LOG_FILE"
  grep "PUNISH" "$LLM_BEHAVIOR_LOG" >> "$REVIEW_SUMMARY_FILE"
}

step4_review_logs() {
  echo "Step 4: Reviewing patterns in logs." >> "$REVIEW_LOG_FILE"
  tail -n 50 "$LLM_BEHAVIOR_LOG" >> "$REVIEW_SUMMARY_FILE"
}

step5_summarize() {
  echo "Step 5: Summarizing insights and re-aligning task plan." >> "$REVIEW_LOG_FILE"
  echo "Summary: LLM appears to be $(tail -n 10 "$REVIEW_SUMMARY_FILE")" >> "$REVIEW_LOG_FILE"
}

# Run all steps sequentially
step1_recall_task
step2_check_outputs
step3_reflect_breaches
step4_review_logs
step5_summarize

echo "[REVIEW] Memory review complete at $(date)" >> "$LOGFILE"
