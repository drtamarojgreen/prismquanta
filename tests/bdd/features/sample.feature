Feature: Sample Feature

  Scenario: A simple test
    Given a file named "test.txt" with content "hello world"
    When I read the file "test.txt"
    Then the content should be "hello world"
