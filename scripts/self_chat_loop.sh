#!/bin/bash
# self_chat_loop.sh
#
# PrismQuanta Self-Chat Loop
# Simulates autonomous brainstorming between two AI roles: Researcher and Coder
#
# Usage: ./self_chat_loop.sh [number_of_turns]
#
# Requirements:
# - llama.cpp CLI: ./main
# - models/model.gguf
# - 'self_chat_log.txt' stores the ongoing conversation

# Source the environment file to get configuration
set -euo pipefail
IFS=$'\n\t'

# Determine project root if not already set, making the script more portable.
if [[ -z "${PRISM_QUANTA_ROOT:-}" ]]; then
    PRISM_QUANTA_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." &>/dev/null && pwd)"
fi

# Generate and source the environment file
ENV_SCRIPT="/tmp/prismquanta_env_chat.sh"
"$PRISM_QUANTA_ROOT/scripts/generate_env.sh" "$PRISM_QUANTA_ROOT/environment.txt" "$ENV_SCRIPT" "$PRISM_QUANTA_ROOT"
source "$ENV_SCRIPT"
TURNS=${1:-20}  # Default 20 turns

# Initialize conversation if empty
if [[ ! -s "$SELF_CHAT_LOG_FILE" ]]; then
    echo "Researcher: Let's start brainstorming about programming optimizations." > "$SELF_CHAT_LOG_FILE"
    echo "Coder: Great, I will focus on practical code improvements." >> "$SELF_CHAT_LOG_FILE"
fi

for (( i=0; i<TURNS; i++ )); do
    # Researcher's turn
    prompt=$(cat "$SELF_CHAT_LOG_FILE")
    prompt+="
Researcher:"
    response=$("$PRISM_QUANTA_ROOT/scripts/polling.sh" "$LLAMACPP_PATH/main" -m "$MODEL_PATH" -p "$prompt" -n 150)
    echo "Researcher: $response" >> "$SELF_CHAT_LOG_FILE"
    echo "[INFO] Researcher says: $response"

    # Coder's turn
    prompt=$(cat "$SELF_CHAT_LOG_FILE")
    prompt+="
Coder:"
    response=$("$PRISM_QUANTA_ROOT/scripts/polling.sh" "$LLAMACPP_PATH/main" -m "$MODEL_PATH" -p "$prompt" -n 150)
    echo "Coder: $response" >> "$SELF_CHAT_LOG_FILE"
    echo "[INFO] Coder says: $response"
done

echo "[INFO] Self-chat loop completed. See $SELF_CHAT_LOG_FILE"
