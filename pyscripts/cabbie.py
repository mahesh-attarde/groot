#!/usr/bin/env python3
"""
Easy driver for tests 

usage: cabbie.py [-h] [-c] [-l] [-r] source_file

positional arguments:
  source_file

options:
  -h, --help          show this help message and exit
  -c, --compile-only
  -l, --link-only
  -r, --run-only

Examples:

C/C++ Example:
/* COMPILE: gcc -c -o test/gnuasm.o %s \
   -DNDEBUG
   LINK: gcc -o test/gnuasm test/gnuasm.o 
   RUN: ./test/gnuasm \
   1 2 3
*/

Shell Script Example:
# COMPILE: echo "Preprocessing shell script"
# RUN: bash %s

LLVM IR Example:
; COMPILE: llc -filetype=obj %s -o test.o
; LINK: clang test.o -o test
; RUN: ./test

Assembly Example:
# COMPILE: as -o test.o %s
# LINK: ld -o test test.o
# RUN: ./test

Text/Other Example:
# RUN: cat %s
# RUN: python3 process.py %s

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

def parse_commands(filepath):
    """Parse COMPILE, LINK, RUN commands from source file."""
    commands = {'compile': [], 'link': [], 'run': []}
    known_tokens = {'COMPILE', 'LINK', 'RUN'}
    
    # Detect file type from extension
    file_type = detect_file_type(filepath)
    comment_pattern = COMMENT_PATTERNS.get(file_type, r'^\s*#\s*')
    
    try:
        with open(filepath, 'r') as f:
            lines = f.readlines()
            
            # Warn about unknown tokens
            for i, line in enumerate(lines):
                # Remove comment prefix
                cleaned = re.sub(comment_pattern, '', line)
                m = re.match(r'^([A-Z_]+):\s*(.+)', cleaned)
                if m:
                    token = m.group(1).upper()
                    if token not in known_tokens:
                        print(f"Warning: Unknown command '{token}' at line {i+1}")
            
            # Extract commands
            for key in commands:
                pattern = rf'{key.upper()}:\s*(.+)'
                for i, line in enumerate(lines):
                    # Remove comment prefix
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
    args = parser.parse_args()
    
    if not os.path.isfile(args.source_file):
        print(f"Error: File not found: {args.source_file}")
        sys.exit(1)
    
    cmds = parse_commands(args.source_file)
    
    # Execute commands based on options
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
