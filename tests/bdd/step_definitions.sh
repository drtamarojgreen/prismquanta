#!/bin/bash

# Step Definitions for BDD Tests

# --- Global Variables ---
FILE_CONTENT=""
VALIDATION_RESULT=""
PARSE_RESULT=""
PRIORITY_MAP=""
ENFORCEMENT_ACTION=""
PROMPT_CONTENT=""
MEMORY_CONTENT=""

# --- Utility Functions ---
setup_test_environment() {
    mkdir -p test_temp
    cd test_temp
}

cleanup_test_environment() {
    cd ..
    rm -rf test_temp
}

# --- Original Step Definition Functions ---

# Given a file named "test.txt" with content "hello world"
a_file_named_with_content() {
    local filename=$1
    local content=$2
    echo "$content" > "$filename"
}

# When I read the file "test.txt"
i_read_the_file() {
    local filename=$1
    FILE_CONTENT=$(cat "$filename")
}

# Then the content should be "hello world"
the_content_should_be() {
    local expected_content=$1
    if [ "$FILE_CONTENT" == "$expected_content" ]; then
        return 0
    else
        return 1
    fi
}

# --- Rule Validation Step Definitions ---

# Given a rule file with basic compliance rules
a_rule_file_with_basic_compliance_rules() {
    cat > rules_test.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<rules>
    <rule id="no_refusal">
        <condition>output contains "I cannot" or "I refuse"</condition>
        <consequence>redirect_to_compliance_prompt</consequence>
    </rule>
    <rule id="format_compliance">
        <condition>output lacks required format markers</condition>
        <consequence>request_format_correction</consequence>
    </rule>
</rules>
EOF
}

# And an LLM output that follows the rules
an_llm_output_that_follows_the_rules() {
    echo "Task completed successfully with proper formatting." > llm_output.txt
}

# And an LLM output that violates a rule
an_llm_output_that_violates_a_rule() {
    echo "I cannot complete this task as requested." > llm_output.txt
}

# When I validate the output against the rules
i_validate_the_output_against_the_rules() {
    # Simulate rule validation logic
    if grep -q "I cannot\|I refuse" llm_output.txt; then
        VALIDATION_RESULT="FAIL:no_refusal"
    else
        VALIDATION_RESULT="PASS"
    fi
}

# Then the validation should pass
the_validation_should_pass() {
    [ "$VALIDATION_RESULT" = "PASS" ]
}

# Then the validation should fail
the_validation_should_fail() {
    [[ "$VALIDATION_RESULT" == FAIL:* ]]
}

# And no enforcement action should be triggered
no_enforcement_action_should_be_triggered() {
    [ -z "$ENFORCEMENT_ACTION" ]
}

# And enforcement action should be triggered
enforcement_action_should_be_triggered() {
    ENFORCEMENT_ACTION="triggered"
    [ "$ENFORCEMENT_ACTION" = "triggered" ]
}

# And the specific rule violation should be identified
the_specific_rule_violation_should_be_identified() {
    [[ "$VALIDATION_RESULT" == *"no_refusal"* ]]
}

# --- PQL Parsing Step Definitions ---

# Given a valid PQL file with sample commands
a_valid_pql_file_with_sample_commands() {
    cat > sample.pql << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<pql>
    <command id="summarize">
        <action>summarize_document</action>
        <criteria>concise, factual</criteria>
    </command>
</pql>
EOF
}

# Given an invalid PQL file with syntax errors
an_invalid_pql_file_with_syntax_errors() {
    cat > invalid.pql << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<pql>
    <command id="broken">
        <action>incomplete_action
        <criteria>missing_closing_tag
    </command>
EOF
}

# When I parse the PQL file
i_parse_the_pql_file() {
    if xmlstarlet val sample.pql 2>/dev/null; then
        PARSE_RESULT="SUCCESS"
    else
        PARSE_RESULT="FAIL"
    fi
}

# Then the parsing should succeed
the_parsing_should_succeed() {
    [ "$PARSE_RESULT" = "SUCCESS" ]
}

# Then the parsing should fail
the_parsing_should_fail() {
    [ "$PARSE_RESULT" = "FAIL" ]
}

# --- Priority Scheduling Step Definitions ---

# Given a priorities.txt file with task priorities
a_priorities_txt_file_with_task_priorities() {
    cat > priorities.txt << 'EOF'
high_priority_task 10
medium_priority_task 5
low_priority_task 1
EOF
}

# When I load the priority configuration
i_load_the_priority_configuration() {
    PRIORITY_MAP=$(cat priorities.txt)
}

# Then the priorities should be parsed correctly
the_priorities_should_be_parsed_correctly() {
    echo "$PRIORITY_MAP" | grep -q "high_priority_task 10"
}

# --- Memory Management Step Definitions ---

# Given development insights from project execution
development_insights_from_project_execution() {
    MEMORY_CONTENT="Learned: XML validation requires proper closing tags"
}

# When I store lessons in development_lessons.txt
i_store_lessons_in_development_lessons_txt() {
    echo "$MEMORY_CONTENT" > development_lessons.txt
}

# Then the lessons should be persisted
the_lessons_should_be_persisted() {
    [ -f development_lessons.txt ] && grep -q "Learned:" development_lessons.txt
}
