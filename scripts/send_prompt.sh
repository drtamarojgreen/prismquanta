#!/bin/bash
# send_prompt.sh - Sends a prompt to the LLM.
# This script relies on environment variables (LLAMACPP_PATH, MODEL_PATH)
# being set and exported by the calling script.

# Source utility functions
source "$(dirname "$0")/utils.sh"

# Setup environment
setup_env

# Check for prompt content from stdin
if ! tty -s; then
  PROMPT_CONTENT=$(cat)
else
  log_error "Prompt content must be piped via stdin."
fi

# Call the LLM with the provided prompt content
RAW_OUTPUT=$("$LLAMACPP_PATH"/llama-cli \
  -m "$MODEL_PATH" \
  -p "$PROMPT_CONTENT" \
  -n 256 \
  --single-turn \
  --no-display-prompt \
  --no-warmup 2>&1)

# Parse the output to extract the generated text
echo "$RAW_OUTPUT" | sed -n '/generate:/,/\[end of text\]/p' | sed '1d;$d'
