# Example Usage:
# ./replace_strings.sh replacements.txt target.txt
# Where:
# - replacements.txt contains lines in the format "str1 str2"
#   (e.g., "foo bar" means replace "foo" with "bar")
# - target.txt is the file where replacements will be made
#!/bin/bash

# Check if the correct number of arguments is provided
if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <replacement_file> <target_file>"
  exit 1
fi

# Assign command line arguments to variables
REPLACEMENT_FILE="$1"
TARGET_FILE="$2"

# Check if the replacement file exists
if [[ ! -f "$REPLACEMENT_FILE" ]]; then
  echo "Replacement file $REPLACEMENT_FILE does not exist."
  exit 1
fi

# Check if the target file exists
if [[ ! -f "$TARGET_FILE" ]]; then
  echo "Target file $TARGET_FILE does not exist."
  exit 1
fi

# Read each line from the replacement file
while IFS=' ' read -r str1 str2; do
  # Replace occurrences of str1 with str2 in the target file
  sed -i "s/$str1/$str2/g" "$TARGET_FILE"
  echo "Replaced '$str1' with '$str2' in $TARGET_FILE"
done < "$REPLACEMENT_FILE"

echo "Replacement complete."
