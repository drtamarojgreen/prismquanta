#!/bin/bash
# define_requirements.sh - Expands strategies into clear, testable requirements

set -euo pipefail
IFS=$'\n\t'

# Source utility functions
source "$(dirname "$0")/utils.sh"

# Setup environment
setup_env

log_info "Generating requirements from strategies..."

cat "$STRATEGY_PLAN_FILE" | "$PRISM_QUANTA_ROOT/scripts/send_prompt.sh" --prompt "Define testable requirements from this plan:" > "$REQUIREMENTS_FILE"

log_info "Requirements written to $REQUIREMENTS_FILE."
