#!/usr/bin/env bats

load '../step_definitions.sh'

@test "A simple test" {
  run step_a_file_named_with_content "test.txt" "hello world"
  run step_i_read_the_file "test.txt"
  run step_the_content_should_be "hello world"
}
