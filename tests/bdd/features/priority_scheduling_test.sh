#!/bin/bash

# Native test file for Priority Scheduling.
# This test addresses the gap where the logic for parsing task priorities
# was not covered by any tests. It ensures that the priority configuration
# can be loaded and parsed correctly at the script level.

# Test: Priority configuration should be loaded and parsed correctly.
# This test verifies that a correctly formatted priorities.txt file
# can be read and that the task priorities within it are correctly identified.
test_priority_configuration_is_loaded_correctly() {
  # Given a priorities.txt file with task priorities
  step_a_priorities_txt_file_with_task_priorities

  # When I load the priority configuration
  step_i_load_the_priority_configuration

  # Then the priorities should be parsed correctly
  step_the_priorities_should_be_parsed_correctly
}
