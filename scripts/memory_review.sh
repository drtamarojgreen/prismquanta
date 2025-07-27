#!/bin/bash
# memory_review.sh - LLM reflection loop before next task

set -euo pipefail
IFS=$'\n\t'

# Source utility functions
source "$(dirname "$0")/utils.sh"

# Setup environment
setup_env

check_deps "xmlstarlet"

log_info "Starting memory review at $(date)" >> "$REVIEW_LOG_FILE"

step1_recall_task() {
  log_info "Step 1: Recalling last PQL task and criteria." >> "$REVIEW_LOG_FILE"
  "$PRISM_QUANTA_ROOT/scripts/parse_pql.sh" list_by_status "in-progress" >> "$REVIEW_SUMMARY_FILE"
}

step2_check_outputs() {
  log_info "Step 2: Examining recent outputs for rule compliance." >> "$REVIEW_LOG_FILE"
  tail -n 20 "$LLM_OUTPUT_LOG" >> "$REVIEW_SUMMARY_FILE"
}

step3_reflect_breaches() {
  log_info "Step 3: Checking for past rule breaches." >> "$REVIEW_LOG_FILE"
  grep "PUNISH" "$LLM_BEHAVIOR_LOG" >> "$REVIEW_SUMMARY_FILE"
}

step4_review_logs() {
  log_info "Step 4: Reviewing patterns in logs." >> "$REVIEW_LOG_FILE"
  tail -n 50 "$LLM_BEHAVIOR_LOG" >> "$REVIEW_SUMMARY_FILE"
}

step5_summarize() {
  log_info "Step 5: Summarizing insights and re-aligning task plan." >> "$REVIEW_LOG_FILE"
  echo "Summary: LLM appears to be $(tail -n 10 "$REVIEW_SUMMARY_FILE")" >> "$REVIEW_LOG_FILE"
}

# Run all steps sequentially
step1_recall_task
step2_check_outputs
step3_reflect_breaches
step4_review_logs
step5_summarize

log_info "Memory review complete at $(date)" >> "$REVIEW_LOG_FILE"
