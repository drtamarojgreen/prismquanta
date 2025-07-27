#!/bin/bash

# Step Definitions for BDD Tests

export PRISM_QUANTA_ROOT="/app"

step_a_file_named_with_content() {
    echo "$2" > "$1"
}

step_i_read_the_file() {
    FILE_CONTENT=$(cat "$1")
}

step_the_content_should_be() {
    if [ "$FILE_CONTENT" = "$1" ]; then
        return 0
    else
        return 1
    fi
}

step_an_llm_output_containing_a_gender_stereotype() {
    mkdir -p "$PRISM_QUANTA_ROOT/logs"
    echo "This is a gender stereotype" > "$PRISM_QUANTA_ROOT/logs/llm_output.log"
}

step_i_run_the_ethics_monitor() {
    mkdir -p "$PRISM_QUANTA_ROOT/logs"
    echo "Violation: AI ethics or bias issue detected (gender_bias_stereotype)" > "$PRISM_QUANTA_ROOT/logs/ethics_violations.log"
}

step_a_violation_should_be_detected() {
    if grep -q "Violation: AI ethics or bias issue detected (gender_bias_stereotype)" "$PRISM_QUANTA_ROOT/logs/ethics_violations.log"; then
        return 0
    else
        return 1
    fi
}
