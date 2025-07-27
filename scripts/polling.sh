#!/bin/bash
# polling.sh
#
# Executes a command in the background and shows a "thinking" message
# while waiting for it to complete.
#
# Usage: ./polling.sh <command>
#

COMMAND_TO_RUN="$@"
OUTPUT_FILE=$(mktemp)
PID_FILE=$(mktemp)

# Run the command in the background
$COMMAND_TO_RUN > "$OUTPUT_FILE" 2>&1 &
echo $! > "$PID_FILE"

PID=$(cat "$PID_FILE")

while ps -p $PID > /dev/null; do
    echo -n "."
    sleep 1
done

echo
cat "$OUTPUT_FILE"
rm "$OUTPUT_FILE"
rm "$PID_FILE"
