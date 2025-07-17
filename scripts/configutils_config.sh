#! /bin/bash

# Function to parse config file where each line is a separate argument
# Usage: parse_config_file <config_file_path>
# Returns: Populates global array CONFIG_ARGS with all arguments

configutils_parse_config_file() {
    local config_file="$1"
    
    LVB_CONFIG_ARGS=()
    
    if [[ ! -f "$config_file" ]]; then
        echo "Error: Config file '$config_file' not found" >&2
        return 1
    fi
    
    while IFS= read -r line || [[ -n "$line" ]]; do
        line=$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        
        if [[ -n "$line" && ! "$line" =~ ^#.* ]]; then
            LVB_CONFIG_ARGS+=("$line")
        fi
    done < "$config_file"
    
    return 0
}

configutils_parse_config_from_string() {
    local config_string="$1"
    LVB_CONFIG_ARGS=()
    
    while IFS= read -r line; do
        line=$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        
        if [[ -n "$line" && ! "$line" =~ ^#.* ]]; then
            LVB_CONFIG_ARGS+=("$line")
        fi
    done <<< "$config_string"
    return 0
}

# Function to print all parsed arguments
#configutils_print_config_args() {
#    echo "Parsed arguments:"
#    for i in "${!LVB_CONFIG_ARGS[@]}"; do
#        echo "  [$i] ${LVB_CONFIG_ARGS[$i]}"
#    done
#}

# Function to get arguments as a single string (space-separated)
configutils_get_config_args_string() {
    printf "%s " "${LVB_CONFIG_ARGS[@]}"
}

# Test Driver
configutils_parser_use() { 
    if configutils_parse_config_file "llvm.conf"; then
        echo "As single string: $(configutils_get_config_args_string)"
    else
        echo "Failed to parse config file"
    fi
}
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    configutils_parser_use "$@"
    unset -f configutils_parse_config_file
fi
