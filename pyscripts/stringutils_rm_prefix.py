import argparse
import re
def delete_lines(input_file, output_file, delimiter, token, del_empty_lines=True):
    pattern_token = re.compile(rf"^{re.escape(delimiter)}\s*{re.escape(token)}")
    pattern_delim_eol = re.compile(rf"^{re.escape(delimiter)}\s*$")
    with open(input_file, 'r') as file:
        lines = file.readlines()

    with open(output_file, 'w') as file:
        for line in lines:
            stripped_line = line.lstrip()
            if pattern_token.match(stripped_line):
                continue
            if pattern_delim_eol.match(stripped_line):
                continue
            file.write(line)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Delete lines starting with a specific delimiter and token.")
    parser.add_argument('input_file', type=str, help='Path to the input file')
    parser.add_argument('delimiter', type=str, help='Delimiter character')
    parser.add_argument('token', type=str, help='Token string')
    parser.add_argument('-o', type=str, help='Path to the output file')
    parser.add_argument('--del_empty_lines', action='store_true', help='Delete empty lines')
    args = parser.parse_args()

    delete_lines(args.input_file, args.o, args.delimiter, args.token, args.del_empty_lines)