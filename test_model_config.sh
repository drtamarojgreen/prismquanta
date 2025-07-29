#!/bin/bash
# test_model_config.sh - A simple script to test the LLM configuration.
# This script uses the system and user prompts to get a response from the model.

set -euo pipefail
IFS=$'\n\t'

# --- Setup ---
# Set the project root and source utilities to load environment variables.
export PRISM_QUANTA_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
source "$PRISM_QUANTA_ROOT/scripts/utils.sh"
setup_env

# --- Configuration ---
# Define paths to the prompt files. The user prompt is from environment.txt.
# We assume a standard name for the system prompt.
SYSTEM_PROMPT_FILE="$PRISM_QUANTA_ROOT/prompts/system_prompt.txt"
USER_PROMPT_FILE="$PRISM_QUANTA_ROOT/$PROMPT_FILE"
INFER_SCRIPT="$PRISM_QUANTA_ROOT/$LLM_INFER_SCRIPT"

# Colors for output
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# --- Main Execution ---
main() {
    echo -e "${BLUE}--- Starting Model Configuration Test ---${NC}"

    # --- Validations ---
    local all_ok=true
    if [[ ! -f "$SYSTEM_PROMPT_FILE" ]]; then
        echo -e "${RED}Error: System prompt not found at: $SYSTEM_PROMPT_FILE${NC}"
        echo "Please create this file with your desired system prompt."
        all_ok=false
    fi
    if [[ ! -f "$USER_PROMPT_FILE" ]]; then
        echo -e "${RED}Error: User prompt not found at: $USER_PROMPT_FILE${NC}"
        echo "This path is configured in environment.txt (PROMPT_FILE)."
        all_ok=false
    fi
    if [[ ! -f "$INFER_SCRIPT" ]]; then
        echo -e "${RED}Error: Inference script not found at: $INFER_SCRIPT${NC}"
        all_ok=false
    elif [[ ! -x "$INFER_SCRIPT" ]]; then
        echo -e "${RED}Error: Inference script is not executable: $INFER_SCRIPT${NC}"
        all_ok=false
    fi
    if [[ ! -f "$PRISM_QUANTA_ROOT/$MODEL_PATH" ]]; then
        echo -e "${RED}Error: Model file not found at: $PRISM_QUANTA_ROOT/$MODEL_PATH${NC}"
        all_ok=false
    fi

    if [[ "$all_ok" == "false" ]]; then
        echo -e "\n${RED}Aborting due to missing files. Please check your configuration.${NC}"
        exit 1
    fi

    # --- Execution ---
    echo "Loading system prompt from: $SYSTEM_PROMPT_FILE"
    echo "Loading user prompt from:   $USER_PROMPT_FILE"
    echo "Using model:                $MODEL_PATH"
    echo "Using inference script:     $LLM_INFER_SCRIPT"
    echo
    echo -e "${BLUE}--- Sending Prompts to Model ---${NC}"

    echo "--- Model Response ---"
    # Execute the inference script, passing the system and user prompt files as arguments.
    # This assumes llm_infer.sh is designed to accept these two files.
    "$INFER_SCRIPT" "$SYSTEM_PROMPT_FILE" "$USER_PROMPT_FILE"

    echo
    echo -e "${GREEN}--- Model Configuration Test Complete ---${NC}"
}

main "$@"