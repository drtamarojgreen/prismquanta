#!/bin/bash

# Native test file for General Rule Validation.
# These tests address the gap identified where the core XML-based rule
# validation system was not covered by any tests.

# Test: Validation should pass for a compliant LLM output.
# This test ensures that when an output follows all rules, the
# validation process completes successfully without flagging any issues.
test_rule_validation_passes_for_compliant_output() {
  # Given a rule file with basic compliance rules
  step_a_rule_file_with_basic_compliance_rules

  # And an LLM output that follows the rules
  step_an_llm_output_that_follows_the_rules

  # When I validate the output against the rules
  step_i_validate_the_output_against_the_rules

  # Then the validation should pass
  step_the_validation_should_pass
}

# Test: Validation should fail for a non-compliant LLM output.
# This test ensures that when an output violates a rule (e.g., by being
# non-committal), the validation process catches the failure and
# correctly identifies the specific rule that was broken.
test_rule_validation_fails_for_non_compliant_output() {
  # Given a rule file with basic compliance rules
  step_a_rule_file_with_basic_compliance_rules

  # And an LLM output that violates a rule
  step_an_llm_output_that_violates_a_rule

  # When I validate the output against the rules
  step_i_validate_the_output_against_the_rules

  # Then the validation should fail
  step_the_validation_should_fail

  # And the specific rule violation should be identified
  step_the_specific_rule_violation_should_be_identified
}
