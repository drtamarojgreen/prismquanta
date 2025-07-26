#!/bin/bash
# send_prompt.sh - Sends a prompt to the LLM.

# Source the environment file to get configuration
source "config/environment.txt"

# Check for prompt content from stdin
if ! tty -s; then
  PROMPT_CONTENT=$(cat)
else
  echo "Error: Prompt content must be piped via stdin." >&2
  exit 1
fi

# Call the LLM with the provided prompt content
"$LLAMACPP_PATH"/llama-cli \
  -m "$MODEL_PATH" \
  -p "$PROMPT_CONTENT" \
  -n 256 \
  --single-turn \
  --no-display-prompt \
  --no-warmup 2>/dev/null
