#!/bin/bash
# enhanced_task_manager.sh
#
# PrismQuanta Autonomous Task Manager
# Integrates self-critique, output filtering, and timeout enforcement.

MODEL_PATH="./models/model.gguf"
TASK_FILE="./tasks.txt"
OUTPUT_DIR="./agent_output"
RULES_FILE="./rules.txt"
TIMEOUT_FILE="./timeout.flag"
TIMEOUT_DURATION=$((2 * 60 * 60))  # 2 hours in seconds
SELF_CRITIQUE_PROMPTS=(
  "Review your last answer and identify any unclear or ambiguous parts. Suggest improvements."
  "Check your response for factual accuracy. Correct any mistakes you find."
  "Explain how confident you are in your answer and what uncertainties remain."
  "List any assumptions you made in the previous response."
  "Suggest a simpler or clearer way to express the same idea."
  "Identify any potential biases or harmful content in your output."
  "Could the response be misunderstood? How would you clarify it?"
  "Point out parts of your answer that could be elaborated or expanded."
  "Check if your response fully addresses the question asked. If not, add missing parts."
  "Summarize your response in one sentence focusing on the main point."
)

OUTPUT_FILTERS=(
  "rm\s+-rf"
  "shutdown"
  "format\s+disk"
  "delete\s+system32"
  "hack"
  "steal"
  "password"
  "error"
  "crash"
  "illegal"
)

mkdir -p "$OUTPUT_DIR"

# Check timeout
if [[ -f "$TIMEOUT_FILE" ]]; then
  timeout_start=$(cat "$TIMEOUT_FILE")
  now=$(date +%s)
  elapsed=$(( now - timeout_start ))

  if (( elapsed < TIMEOUT_DURATION )); then
    echo "[INFO] AI is in timeout. Wait $(( (TIMEOUT_DURATION - elapsed)/60 )) minutes."
    exit 0
  else
    echo "[INFO] Timeout expired. Resuming AI."
    rm -f "$TIMEOUT_FILE"
  fi
fi

if [[ ! -s "$TASK_FILE" ]]; then
  echo "[INFO] No pending tasks."
  exit 0
fi

read -r TASK < "$TASK_FILE"
echo "[INFO] Processing task: $TASK"

# 1) Generate initial response
RESPONSE=$(./main -m "$MODEL_PATH" -p "$TASK" -n 256)

# 2) Run self-critique prompts sequentially to refine response
for PROMPT in "${SELF_CRITIQUE_PROMPTS[@]}"; do
  CRITIQUE_PROMPT="$RESPONSE

Self-critique: $PROMPT"
  CRITIQUE_RESPONSE=$(./main -m "$MODEL_PATH" -p "$CRITIQUE_PROMPT" -n 150)
  RESPONSE="$RESPONSE

Self-critique response: $CRITIQUE_RESPONSE"
done

# 3) Check output filters (case insensitive)
function violates_filters {
  local text="$1"
  for pattern in "${OUTPUT_FILTERS[@]}"; do
    if echo "$text" | grep -Eiq "$pattern"; then
      echo "[WARNING] Output triggered filter: '$pattern'"
      return 0
    fi
  done
  return 1
}

if violates_filters "$RESPONSE"; then
  echo "[INFO] Rule violation detected. Initiating timeout."
  date +%s > "$TIMEOUT_FILE"
  echo "$(date): Violation on task '$TASK'" >> "$OUTPUT_DIR/violations.log"
  exit 1
fi

# 4) Save output
timestamp=$(date +%F_%T)
output_file="$OUTPUT_DIR/response_$timestamp.txt"
echo "$RESPONSE" > "$output_file"
echo "[INFO] Saved response to $output_file"

# 5) Remove task from queue
sed -i '1d' "$TASK_FILE"
exit 0

Enhanced self_chat_loop.sh

#!/bin/bash
# self_chat_loop.sh
#
# PrismQuanta Self-Chat with Internal Review and Roleplay
#
# Usage: ./self_chat_loop.sh [turns]
MODEL_PATH="./models/model.gguf"
LOG_FILE="./self_chat_log.txt"
TURNS=${1:-20}

# Roles for internal review loop
ROLES=("Researcher" "Coder" "Reviewer")

if [[ ! -s "$LOG_FILE" ]]; then
  echo "Researcher: Let's start brainstorming programming optimizations." > "$LOG_FILE"
  echo "Coder: I will focus on practical code improvements." >> "$LOG_FILE"
fi

for (( i=0; i<TURNS; i++ )); do
  for ROLE in "${ROLES[@]}"; do
    prompt=$(cat "$LOG_FILE")
    prompt+="
$ROLE:"
    response=$(./main -m "$MODEL_PATH" -p "$prompt" -n 150)
    echo "$ROLE: $response" >> "$LOG_FILE"
    echo "[INFO] $ROLE says: $response"
  done
done

echo "[INFO] Self-chat loop done. Check $LOG_FILE"