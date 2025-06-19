import argparse

def delete_lines(input_file, output_file, delimiter, token):
    with open(input_file, 'r') as file:
        lines = file.readlines()

    with open(output_file, 'w') as file:
        for line in lines:
            stripped_line = line.lstrip()  # Remove leading white spaces
            if not stripped_line.startswith(f"{delimiter} {token}"):
                file.write(line)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Delete lines starting with a specific delimiter and token.")
    parser.add_argument('input_file', type=str, help='Path to the input file')
    parser.add_argument('delimiter', type=str, help='Delimiter character')
    parser.add_argument('token', type=str, help='Token string')
    parser.add_argument('-o', type=str, help='Path to the output file')

    args = parser.parse_args()

    delete_lines(args.input_file, args.o, args.delimiter, args.token)