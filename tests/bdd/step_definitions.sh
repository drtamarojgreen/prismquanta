#!/bin/bash

# Step Definitions for BDD Tests

# --- Step Definition Functions ---

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
