#!/bin/bash

MAX_RETRIES=5
RETRY_COUNT=0
VALID_RESPONSE=""

generate_prompt() {
  # Fill prompt template with PQL + reflection data (can be a call to a Python or bash script)
  # Output prompt to file or stdout
  ./build_prompt.sh > current_prompt.txt
}

call_llm() {
  # Replace with your actual LLM call
  ./llm_infer.sh --prompt current_prompt.txt > current_response.txt
}

check_rules() {
  # Implement rule violation checks on current_response.txt
  # Return 0 if passes, non-zero if violations found
  grep -i "FORBIDDEN" current_response.txt >/dev/null && return 1
  return 0
}

apply_penalty() {
  # Append penalty or reflection instructions to prompt
  echo "You violated a rule, please reconsider and revise your response." >> current_prompt.txt
}

while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
  generate_prompt
  call_llm

  if check_rules; then
    VALID_RESPONSE=$(cat current_response.txt)
    break
  else
    echo "Violation detected. Applying penalty and retrying..."
    apply_penalty
    RETRY_COUNT=$((RETRY_COUNT + 1))
  fi
done

if [ -z "$VALID_RESPONSE" ]; then
  echo "Failed to generate valid response after $MAX_RETRIES attempts."
  exit 1
fi

echo "Valid response generated:"
echo "$VALID_RESPONSE"
