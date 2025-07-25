#!/bin/bash

# Step Definitions for BDD Tests

an_llm_output_containing_a_gender_stereotype() {
    echo "This is a gender stereotype" > ../../logs/llm_output.log
}

i_run_the_ethics_monitor() {
    (cd ../.. && bash scripts/ethics_monitor.sh &)
    sleep 1
    kill $!
}

a_violation_should_be_detected() {
    if grep -q "Violation: AI ethics or bias issue detected (gender_bias_stereotype)" ../../logs/ethics_violations.log; then
        return 0
    else
        return 1
    fi
}
