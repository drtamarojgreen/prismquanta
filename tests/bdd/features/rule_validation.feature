Feature: Rule Validation and Enforcement

  Scenario: Rule validation passes for compliant output
    Given a rule file with basic compliance rules
    And an LLM output that follows the rules
    When I validate the output against the rules
    Then the validation should pass
    And no enforcement action should be triggered

  Scenario: Rule validation fails for non-compliant output
    Given a rule file with basic compliance rules
    And an LLM output that violates a rule
    When I validate the output against the rules
    Then the validation should fail
    And the specific rule violation should be identified
    And enforcement action should be triggered

  Scenario: Consequence application for rule violations
    Given a rule with defined consequences
    And a rule violation has been detected
    When I apply the consequence
    Then the appropriate enforcement action should be executed
    And the action should be logged

  Scenario: Rule enforcement modifies prompt flow
    Given a rule violation requiring prompt modification
    When enforcement is applied
    Then the input prompt should be updated
    And the updated prompt should reflect the consequence
