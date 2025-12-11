#!/usr/bin/env python3
"""
Easy driver for tests 

usage: cabbie.py [-h] [-c] [-l] [-r] [-p PREFIX] source_file

positional arguments:
  source_file

options:
  -h, --help            show this help message and exit
  -c, --compile-only    Only run compile commands
  -l, --link-only       Only run link commands
  -r, --run-only        Only run execution commands
  -p PREFIX, --prefix PREFIX
                        Run only specific custom command prefixes (comma-separated)

Examples:

Standard workflow (COMPILE, LINK, RUN):
  python3 cabbie.py test.c
  python3 cabbie.py -c test.c          # compile only
  python3 cabbie.py -r test.ll         # run only

Custom command prefix workflow:
  python3 cabbie.py -p VERIFY test.c   # run only VERIFY commands
  python3 cabbie.py -p QUICK,SMOKE test.c  # run QUICK and SMOKE commands

C/C++ Example:
/* COMPILE: gcc -c -o test/gnuasm.o %s \
   -DNDEBUG
   LINK: gcc -o test/gnuasm test/gnuasm.o 
   RUN: ./test/gnuasm \
   1 2 3
   VERIFY: ./verify_output.sh
   SMOKE: ./smoke_test.sh
*/

Shell Script Example:
# COMPILE: echo "Preprocessing shell script"
# RUN: bash %s
# QUICK: ./quick_sanity.sh

LLVM IR Example:
; COMPILE: llc -filetype=obj %s -o test.o
; LINK: clang test.o -o test
; RUN: ./test
; VERIFY: llvm-lit %s

Assembly Example:
# COMPILE: as -o test.o %s
# LINK: ld -o test test.o
# RUN: ./test
# VALIDATE: objdump -d test

Text/Other Example:
# RUN: cat %s
# RUN: python3 process.py %s
# CHECK: python3 validate.py %s

"""

import sys, os, re, subprocess, argparse

# ANSI color codes
RED = '\033[91m'
RESET = '\033[0m'

# Comment patterns for different file types
COMMENT_PATTERNS = {
    'c': r'^\s*(?://|\*|/\*)\s*',
    'cpp': r'^\s*(?://|\*|/\*)\s*',
    'shell': r'^\s*#\s*',
    'llvm-ir': r'^\s*;\s*',
    'asm': r'^\s*(?:#|;)\s*',
    'text': r'^\s*#\s*',
}

# Standard command types
STANDARD_TOKENS = {'COMPILE', 'LINK', 'RUN'}

def detect_file_type(filepath):
    """Auto-detect file type based on extension."""
    ext = os.path.splitext(filepath)[1].lower()
    ext_map = {
        '.c': 'c',
        '.cpp': 'cpp',
        '.cc': 'cpp',
        '.cxx': 'cpp',
        '.sh': 'shell',
        '.bash': 'shell',
        '.ll': 'llvm-ir',
        '.s': 'asm',
        '.S': 'asm',
        '.asm': 'asm',
        '.txt': 'text',
    }
    return ext_map.get(ext, 'text')

def parse_commands(filepath, custom_prefixes=None):
    """Parse COMPILE, LINK, RUN and custom command prefixes from source file."""
    commands = {'compile': [], 'link': [], 'run': []}
    
    # If custom prefixes provided, create entries for them
    if custom_prefixes:
        for prefix in custom_prefixes:
            commands[prefix.lower()] = []
    
    # Detect file type from extension
    file_type = detect_file_type(filepath)
    comment_pattern = COMMENT_PATTERNS.get(file_type, r'^\s*#\s*')
    
    # Collect all tokens we're looking for
    all_tokens = set(STANDARD_TOKENS)
    if custom_prefixes:
        all_tokens.update(prefix.upper() for prefix in custom_prefixes)
    
    try:
        with open(filepath, 'r') as f:
            lines = f.readlines()
            
            # Warn about unknown tokens (only if not in custom prefix mode)
            if not custom_prefixes:
                for i, line in enumerate(lines):
                    cleaned = re.sub(comment_pattern, '', line)
                    m = re.match(r'^([A-Z_]+):\s*(.+)', cleaned)
                    if m:
                        token = m.group(1).upper()
                        if token not in STANDARD_TOKENS:
                            print(f"Warning: Unknown command '{token}' at line {i+1}")
            
            # Extract commands for all tokens
            for token in all_tokens:
                key = token.lower()
                if key not in commands:
                    commands[key] = []
                    
                pattern = rf'{token}:\s*(.+)'
                for i, line in enumerate(lines):
                    cleaned = re.sub(comment_pattern, '', line)
                    m = re.search(pattern, cleaned, re.IGNORECASE)
                    if m:
                        cmd = m.group(1).strip()
                        j = i + 1
                        # Handle line continuations
                        while cmd.endswith('\\') and j < len(lines):
                            next_line = re.sub(comment_pattern, '', lines[j])
                            cmd = cmd[:-1].strip() + ' ' + next_line.strip()
                            j += 1
                        # Replace %s with filepath
                        cmd = cmd.replace('%s', filepath)
                        commands[key].append(cmd)
                        
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)
    return commands

def run_cmd(cmd, desc, idx):
    """Execute a command and print output."""
    print(f"\n[{desc}[{idx}]] {cmd}")
    result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    if result.stdout:
        print(result.stdout, end='')
    if result.stderr:
        print(f"{RED}{result.stderr}{RESET}", end='')
    if result.returncode != 0:
        print(f"{RED}Failed with exit code {result.returncode}{RESET}")
        sys.exit(1)

def main():
    parser = argparse.ArgumentParser(description='Easy driver for tests')
    parser.add_argument('source_file', help='Source file to process')
    parser.add_argument('-c', '--compile-only', action='store_true',
                       help='Only run compile commands')
    parser.add_argument('-l', '--link-only', action='store_true',
                       help='Only run link commands')
    parser.add_argument('-r', '--run-only', action='store_true',
                       help='Only run execution commands')
    parser.add_argument('-p', '--prefix', type=str,
                       help='Run only specific custom command prefixes (comma-separated, e.g., VERIFY,SMOKE)')
    args = parser.parse_args()
    
    if not os.path.isfile(args.source_file):
        print(f"Error: File not found: {args.source_file}")
        sys.exit(1)
    
    # Parse custom prefixes if provided
    custom_prefixes = None
    if args.prefix:
        custom_prefixes = [prefix.strip().upper() for prefix in args.prefix.split(',')]
        print(f"Running custom command prefixes: {', '.join(custom_prefixes)}")
    
    cmds = parse_commands(args.source_file, custom_prefixes)
    
    # If custom prefix mode, only run custom commands
    if args.prefix:
        for prefix in custom_prefixes:
            key = prefix.lower()
            if key in cmds and cmds[key]:
                for i, cmd in enumerate(cmds[key]):
                    run_cmd(cmd, prefix, i)
            else:
                print(f"Warning: No commands found for prefix '{prefix}'")
    else:
        # Standard mode: run compile, link, run
        if not args.run_only:
            for i, cmd in enumerate(cmds['compile']):
                run_cmd(cmd, 'COMPILE', i)
                
        if not args.compile_only and not args.run_only:
            for i, cmd in enumerate(cmds['link']):
                run_cmd(cmd, 'LINK', i)
                
        if not args.compile_only and not args.link_only:
            for i, cmd in enumerate(cmds['run']):
                run_cmd(cmd, 'RUN', i)

if __name__ == '__main__':
    main()
