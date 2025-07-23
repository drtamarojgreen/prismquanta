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

MODEL_PATH="./models/model.gguf"
LOG_FILE="./self_chat_log.txt"
TURNS=${1:-20}  # Default 20 turns

# Initialize conversation if empty
if [[ ! -s "$LOG_FILE" ]]; then
    echo "Researcher: Let's start brainstorming about programming optimizations." > "$LOG_FILE"
    echo "Coder: Great, I will focus on practical code improvements." >> "$LOG_FILE"
fi

for (( i=0; i<TURNS; i++ )); do
    # Researcher's turn
    prompt=$(cat "$LOG_FILE")
    prompt+="
Researcher:"
    response=$(./main -m "$MODEL_PATH" -p "$prompt" -n 150)
    echo "Researcher: $response" >> "$LOG_FILE"
    echo "[INFO] Researcher says: $response"

    # Coder's turn
    prompt=$(cat "$LOG_FILE")
    prompt+="
Coder:"
    response=$(./main -m "$MODEL_PATH" -p "$prompt" -n 150)
    echo "Coder: $response" >> "$LOG_FILE"
    echo "[INFO] Coder says: $response"
done

echo "[INFO] Self-chat loop completed. See $LOG_FILE"
