#!/bin/bash
# Script to make patch file out of all changed file
# git_make_patches --out /path/ --staged 

git_make_patches(){
#!/bin/bash

# Default values
outdir="."
diff_cmd="git diff"
files=$(git diff --name-only)

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --staged)
      diff_cmd="git diff --cached"
      files=$(git diff --cached --name-only)
      shift
      ;;
    --out)
      outdir="$2"
      shift 2
      ;;
    *)
      shift
      ;;
  esac
done

# Ensure output directory exists
mkdir -p "$outdir"

for file in $files; do
  patch_name="${file//\//_}.patch"
  # Create patch, then remove trailing whitespace from each line
  $diff_cmd "$file" | sed 's/[[:space:]]\+$//' > "$outdir/$patch_name"
done
}
