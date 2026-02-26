#!/bin/bash

# Check for mandatory arguments
if [ "$#" -lt 3 ]; then
    echo "Usage: $0 \"START_MARKER\" \"END_MARKER\" \"FILE_OR_DIR\""
    echo "Example: $0 \"#if FEATURE\" \"#endif // FEATURE\" ./src"
    exit 1
fi

START_MARKER=$1
END_MARKER=$2
TARGET=$3

if [ -d "$TARGET" ]; then
    FILES=$(grep -rl "$START_MARKER" "$TARGET")
else
    FILES=$TARGET
fi

if [ -z "$FILES" ]; then
    echo "No files found containing: $START_MARKER"
    exit 0
fi

for FILE in $FILES; do
    if [ -f "$FILE" ]; then
        echo "Processing: $FILE"
        # Deletes from START to END inclusive
        sed -i "/$START_MARKER/,/$END_MARKER/d" "$FILE"
    else
        echo "Skipping: $FILE (not a valid file)"
    fi
done
echo "BLOCKS DELETED!"
