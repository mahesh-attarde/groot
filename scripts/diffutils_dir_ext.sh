
#!/bin/bash
# Take diff of all comman files from arg1 and arg2  with extension arg3
# E.g. diffutils_dir_ext.sh  /usr/dir1 /usr/dir2 txt
#
#
# Define the directories
DIR_A=$1
DIR_B=$2
ext=$3
# Define the output file
OUTPUT_FILE="diff_output.txt"

# Clear the output file if it exists
> "$OUTPUT_FILE"

# Check if both directories exist
if [[ ! -d "$DIR_A" || ! -d "$DIR_B" ]]; then
  echo "One or both directories do not exist."
  exit 1
fi

# Iterate over all .s files in DirectoryA
for file_a in "$DIR_A"/*.$ext; do
  # Extract the filename without the directory path
  filename=$(basename "$file_a")
  
  # Construct the corresponding file path in DirectoryB
  file_b="$DIR_B/$filename"
  
  if [[ -f "$file_b" ]]; then
    echo "Comparing $filename:" >> "$OUTPUT_FILE"
    # Perform the diff operation and append the output to the file
    diff -u "$file_a" "$file_b" >> "$OUTPUT_FILE"
    echo "----------------------------------------" >> "$OUTPUT_FILE"
  else
    echo "File $filename does not exist in $DIR_B." >> "$OUTPUT_FILE"
  fi
done
