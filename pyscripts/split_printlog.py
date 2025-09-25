import argparse
import os
import re

def split_log(input_file, out_dir="."):
    # Read the entire log file
    with open(input_file, "r") as f:
        content = f.read()

    # Find all start markers and passnames
    pattern = r'; \*\*\* IR Dump After\s+([^\n"]+|"[^"]+")'
    matches = list(re.finditer(pattern, content))

    if not matches:
        print("No IR dump markers found.")
        return

    # Ensure output directory exists
    os.makedirs(out_dir, exist_ok=True)

    for idx, match in enumerate(matches):
        start = match.start()
        end = matches[idx + 1].start() if idx + 1 < len(matches) else len(content)
        # Get first word after start token
        first_line = content[start:end].splitlines()[0]
        tokens = first_line.split()
        passname = tokens[tokens.index("After")+1] if "After" in tokens and len(tokens) > tokens.index("After")+1 else "unknown"
        filename = os.path.join(out_dir, f"{idx+1}.{passname}.ll")
        with open(filename, "w") as out:
            out.write(content[start:end])
        print(f"Wrote {filename}")

def main():
    parser = argparse.ArgumentParser(description="Split IR dump log into multiple files by pass markers.")
    parser.add_argument("input", help="Input log file")
    parser.add_argument("--out-dir", default=".", help="Output directory (default: current dir)")
    args = parser.parse_args()

    split_log(args.input, args.out_dir)

if __name__ == "__main__":
    main()