#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 3 ]]; then
  echo "Usage: $0 <path> <KEY> <NEWKEY>"
  return
fi

TARGET_PATH="$1"
KEY="$2"
NEWKEY="$3"

if [[ ! -d "$TARGET_PATH" ]]; then
  echo "Error: '$TARGET_PATH' is not a valid directory."
  return
fi


find "$TARGET_PATH" -depth | while IFS= read -r item; do
  base="$(basename "$item")"
  dir="$(dirname "$item")"

  if [[ "$base" == *"$KEY"* ]]; then
    newbase="${base//$KEY/$NEWKEY}"
    newpath="$dir/$newbase"

    if [[ "$item" != "$newpath" ]]; then
      echo -e "Renamed: $item ->$newpath"
      mv -- "$item" "$newpath"
    fi
  fi
done