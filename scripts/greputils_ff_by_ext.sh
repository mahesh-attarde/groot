#!/bin/bash

# Function to display help information
show_help() {
    echo "Usage: $0 [options] <directory> <extension> <search_string>"
    echo
    echo "Options:"
    echo "  -h, --help      Show this help message and exit"
    echo
    echo "Arguments:"
    echo "  <directory>     The directory to search in"
    echo "  <extension>     The file extension to look for (e.g., txt)"
    echo "  <search_string> The string to search for within the files"
    echo
    echo "Example:"
    echo "  $0 ./ txt search"
}

# Function to find files by extension and search for a string
greputils_ff_by_ext() {
    local directory="$1"
    local extension="$2"
    local search_string="$3"

    # Use find command to locate files and grep to search for the string
    find "$directory" -type f -name "*.$extension" -exec grep -q "$search_string" {} \; -print
}

# Check for help option
if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
    show_help
    exit 0
fi

# Check if the correct number of arguments is provided
if [ "$#" -ne 3 ]; then
    echo "Error: Incorrect number of arguments."
    show_help
    exit 1
fi

# Call the function with command line arguments
greputils_ff_by_ext "$1" "$2" "$3"
