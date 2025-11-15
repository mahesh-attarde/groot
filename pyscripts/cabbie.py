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

/* COMPILE: gcc -c -o test/gnuasm.o test/gnuasm.c \
   -DNDEBUG
   LINK: gcc -o test/gnuasm test/gnuasm.o 
   RUN: ./test/gnuasm \
   1 2 3
   COMPILE: gcc -c -o test/gnuasm.o test/gnuasm.c 
   LINK: gcc -o test/gnuasm test/gnuasm.o 
   RUN: ./test/gnuasm
*/

#include <stdio.h>
#ifndef NDEBUG
#define PRINT printf("Hello, World! %d\n", argc);
#else
#define	PRINT printf("Hello, World!\n");	
#endif 
void main(int argc, char **argv)
{
	PRINT
}

"""


import sys, os, re, subprocess, argparse

def parse_commands(filepath):
    commands = {'compile': [], 'link': [], 'run': []}
    known_tokens = {'COMPILE', 'LINK', 'RUN'}
    try:
        with open(filepath, 'r') as f:
            lines = [f.readline() for _ in range(100)]
            for i, line in enumerate(lines):
                m = re.match(r'^\s*([A-Z_]+):\s*(.+)', line)
                if m:
                    token = m.group(1).upper()
                    if token not in known_tokens:
                        print(f"Warning: Unknown command '{token}' at line {i+1}")
            for key in commands:
                pattern = rf'{key.upper()}:\s*(.+)'
                for i, line in enumerate(lines):
                    m = re.search(pattern, line, re.IGNORECASE)
                    if m:
                        cmd = m.group(1).strip()
                        j = i + 1
                        while cmd.endswith('\\') and j < len(lines):
                            cmd = cmd[:-1].strip() + ' ' + lines[j].strip()
                            j += 1
                        commands[key].append(cmd)
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)
    return commands

def run_cmd(cmd, desc, idx):
    print(f"\n[{desc}[{idx}]] {cmd}")
    result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    if result.stdout:
        print(result.stdout, end='')
    if result.stderr:
        print(result.stderr, end='')
    if result.returncode != 0:
        print(f"Failed with exit code {result.returncode}")
        sys.exit(1)

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('source_file')
    parser.add_argument('-c', '--compile-only', action='store_true')
    parser.add_argument('-l', '--link-only', action='store_true')
    parser.add_argument('-r', '--run-only', action='store_true')
    args = parser.parse_args()
    
    if not os.path.isfile(args.source_file):
        print(f"Error: File not found")
        sys.exit(1)
    
    cmds = parse_commands(args.source_file)
    
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
