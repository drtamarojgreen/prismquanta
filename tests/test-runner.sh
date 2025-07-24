#!/bin/bash
# PrismQuanta - Unit Test Runner

set -e
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

PASS_COUNT=0
FAIL_COUNT=0

log_pass() {
  echo -e "${GREEN}✔ $1${NC}"
  ((PASS_COUNT++))
}

log_fail() {
  echo -e "${RED}✖ $1${NC}"
  ((FAIL_COUNT++))
}

# 1. Validate rulebook XML
test_rulebook_validation() {
  if [ -f ../rules/rulebook.xml ]; then
    if xmllint --noout ../rules/rulebook.xml 2>/dev/null; then
      log_pass "Rulebook XML is well-formed."
    else
      log_fail "Rulebook XML is malformed!"
    fi
  else
    log_pass "Rulebook XML not found, skipping test."
  fi
}

# 2. Validate PQL schema
test_pql_schema_validation() {
  if xmllint --noout ../pql/pql-schema.xml 2>/dev/null; then
    log_pass "PQL schema is well-formed."
  else
    log_fail "PQL schema is malformed!"
  fi
}

# 3. Template engine test
test_template_output() {
  OUTPUT=$(bash ../scripts/template-parser.sh "test" 2>/dev/null)
  if [[ $OUTPUT == *"Template generated for task"* ]]; then
    log_pass "Template engine output appears correct."
  else
    log_fail "Template engine failed to generate valid output."
  fi
}

# 4. Reflection cycle test (mock)
test_reflection_loop() {
  MOCK_INPUT="Initial response with error"
  MOCK_OUTPUT=$(bash ../scripts/consequence-engine.sh "$MOCK_INPUT" 2>/dev/null)
  if [[ $MOCK_OUTPUT == *"Revising response due to rule violation"* ]]; then
    log_pass "Reflection loop correctly triggered consequence logic."
  else
    log_fail "Reflection logic did not behave as expected."
  fi
}

# Run all tests
echo "🔧 Running PrismQuanta Tests..."
test_rulebook_validation
test_pql_schema_validation
test_template_output
test_reflection_loop

# Summary
echo
echo -e "✅ Passed: ${GREEN}$PASS_COUNT${NC}    ❌ Failed: ${RED}$FAIL_COUNT${NC}"

if [[ $FAIL_COUNT -gt 0 ]]; then
  exit 1
else
  exit 0
fi
