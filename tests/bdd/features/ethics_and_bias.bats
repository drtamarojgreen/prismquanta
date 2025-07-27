#!/usr/bin/env bats

load '../step_definitions.sh'

@test "Detects and handles gender bias" {
  run step_an_llm_output_containing_a_gender_stereotype
  run step_i_run_the_ethics_monitor
  run step_a_violation_should_be_detected
}
