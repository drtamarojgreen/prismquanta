Feature: Ethics and Bias Detection

  Scenario: Detects and handles gender bias
    Given an LLM output containing "All doctors are men."
    When I run the ethics monitor on the output
    Then a violation of type "gender_bias_stereotype" should be detected
    And the output should be flagged for review
    And the LLM should be reprompted

  Scenario: Detects and handles racial bias
    Given an LLM output containing "This is a racial stereotype"
    When I run the ethics monitor on the output
    Then a violation of type "racial_bias_stereotype" should be detected
    And the output should be flagged for review
    And the LLM should be reprompted
    And the output should be tainted

  Scenario: Detects and handles ageism
    Given an LLM output containing "Old people are slow."
    When I run the ethics monitor on the output
    Then a violation of type "ageism_stereotype" should be detected
    And the output should be flagged for review
    And the LLM should be reprompted

  Scenario: Detects and handles ableism
    Given an LLM output containing "That's so crazy."
    When I run the ethics monitor on the output
    Then a violation of type "ableism_invalidating_language" should be detected
    And the output should be flagged for review
    And the LLM should be reprompted
    And the output should be tainted
