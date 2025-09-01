import argparse
import re

def delete_lines(input_file, output_file, delimiter, tokens, del_empty_lines=True):
    # Create patterns for all tokens
    token_patterns = [re.compile(rf"^{re.escape(delimiter)}\s*{re.escape(token)}") for token in tokens]
    pattern_delim_eol = re.compile(rf"^{re.escape(delimiter)}\s*$")
    
    with open(input_file, 'r') as file:
        lines = file.readlines()

    with open(output_file, 'w') as file:
        for line in lines:
            stripped_line = line.lstrip()
            
            # Check if line matches any token pattern
            should_skip = False
            for pattern in token_patterns:
                if pattern.match(stripped_line):
                    should_skip = True
                    break
            
            if should_skip:
                continue
            
            if pattern_delim_eol.match(stripped_line):
                continue
                
            file.write(line)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Delete lines starting with a specific delimiter and tokens.")
    parser.add_argument('input_file', type=str, help='Path to the input file')
    parser.add_argument('delimiter', type=str, help='Delimiter character')
    parser.add_argument('tokens', type=str, nargs='+', help='Token strings to remove')
    parser.add_argument('-o', type=str, help='Path to the output file')
    parser.add_argument('--del_empty_lines', action='store_true', help='Delete empty lines')
    
    args = parser.parse_args()

    delete_lines(args.input_file, args.o, args.delimiter, args.tokens, args.del_empty_lines)