#!/usr/bin/env python3
"""
Parallel Command Executor - GNU parallel-like functionality in Python.

Executes commands from a file in parallel using a process pool. Each command's output
is captured in a temporary file, then all outputs are concatenated into a final log.

USAGE:
    parallel_exec.py [OPTIONS] COMMAND_FILE

BASIC EXAMPLES:
    # Run all commands with default 32 parallel jobs
    parallel_exec.py commands.txt

    # Run with 16 parallel jobs
    parallel_exec.py commands.txt -j 16

    # Run with custom output file
    parallel_exec.py commands.txt -o my_results.log

VERBOSITY EXAMPLES:
    # Quiet mode - only show failures and summary
    parallel_exec.py commands.txt -q

    # Normal mode (default) - show all command results
    parallel_exec.py commands.txt

    # Verbose mode - show additional details like temp file locations
    parallel_exec.py commands.txt -vv

    # Disable colored output
    parallel_exec.py commands.txt --no-color

RANGE SELECTION EXAMPLES:
    # Execute only commands 5 through 10
    parallel_exec.py commands.txt --range 5:10

    # Execute first 5 commands
    parallel_exec.py commands.txt --range :5

    # Execute from command 10 to end
    parallel_exec.py commands.txt --range 10:

    # Execute commands 3-7 with 4 parallel jobs
    parallel_exec.py commands.txt --range 3:7 -j 4

SERIAL EXECUTION EXAMPLES:
    # Run all commands serially (one at a time)
    parallel_exec.py commands.txt -s 1

    # Run first 4 commands in parallel, then rest serially
    parallel_exec.py commands.txt -s 5 -j 4

    # Combined: run commands 10-20, first 3 parallel, rest serial
    parallel_exec.py commands.txt --range 10:20 -s 13 -j 8

EXECUTION CONTROL EXAMPLES:
    # Stop execution if any command fails
    parallel_exec.py commands.txt --halt-on-error

    # Maintain command order in output (slower but ordered)
    parallel_exec.py commands.txt --keep-order

    # Dry run - see what would be executed without running
    parallel_exec.py commands.txt --dry-run

DEBUG EXAMPLES:
    # Keep temporary files for debugging
    parallel_exec.py commands.txt --keep-temp

    # Verbose mode with temp file locations
    parallel_exec.py commands.txt -vv --keep-temp

COMMAND FILE FORMAT:
    - One command per line
    - Lines starting with '#' are treated as comments
    - Empty lines are ignored
    
    Example commands.txt:
        # Build commands
        make clean
        make -j4
        
        # Test commands
        ./run_tests.sh
        python test_suite.py

REAL-WORLD EXAMPLES:
    # Compile multiple files in parallel
    parallel_exec.py compile_commands.txt -j 8

    # Run test suite with first test serial, rest parallel
    parallel_exec.py test_commands.txt -s 2 -j 16

    # Process batch of commands, save to custom log, quiet mode
    parallel_exec.py batch_process.txt -j 32 -o results.log -q

    # Execute subset of long command list for debugging
    parallel_exec.py all_commands.txt --range 45:50 -vv --keep-temp

    # Run critical commands serially, stop on first failure
    parallel_exec.py critical_ops.txt -s 1 --halt-on-error

OUTPUT:
    - Console: Real-time progress with colored status (SUCCESS/FAILED)
    - Log file: Complete execution log with all command outputs
    - Exit code: 0 if all succeeded, 1 if any failed, 130 if interrupted

"""

import argparse
import subprocess
import sys
from multiprocessing import Pool
from typing import Tuple, Optional
import time
import tempfile
import os


# ANSI color codes
class Colors:
    """ANSI color codes for terminal output."""
    RED = '\033[91m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    BLUE = '\033[94m'
    MAGENTA = '\033[95m'
    CYAN = '\033[96m'
    WHITE = '\033[97m'
    RESET = '\033[0m'
    BOLD = '\033[1m'
    
    @staticmethod
    def disable():
        """Disable colors."""
        Colors.RED = ''
        Colors.GREEN = ''
        Colors.YELLOW = ''
        Colors.BLUE = ''
        Colors.MAGENTA = ''
        Colors.CYAN = ''
        Colors.WHITE = ''
        Colors.RESET = ''
        Colors.BOLD = ''


def execute_command(args_tuple: Tuple[int, str, str]) -> Tuple[int, int, str, str, str]:
    """
    Execute a single command and write output to a temporary file.
    
    Args:
        args_tuple: Tuple of (command_index, command, temp_dir)
        
    Returns:
        Tuple of (command_index, return_code, command, temp_file_path, error_msg)
    """
    cmd_index, cmd, temp_dir = args_tuple
    temp_file_path = os.path.join(temp_dir, f"cmd_{cmd_index:06d}.log")
    
    try:
        with open(temp_file_path, 'w') as f:
            # Write header
            f.write(f"{'='*70}\n")
            f.write(f"Command #{cmd_index + 1}: {cmd}\n")
            f.write(f"{'='*70}\n\n")
            f.flush()
            
            # Execute command and redirect output to temp file
            result = subprocess.run(
                cmd,
                shell=True,
                stdout=f,
                stderr=subprocess.STDOUT,
                text=True,
                timeout=None
            )
            
            # Write footer
            f.write(f"\n{'='*70}\n")
            f.write(f"Exit Code: {result.returncode}\n")
            f.write(f"{'='*70}\n\n")
            
        return (cmd_index, result.returncode, cmd, temp_file_path, "")
    except subprocess.TimeoutExpired:
        with open(temp_file_path, 'a') as f:
            f.write("\nERROR: Command timed out\n")
        return (cmd_index, -1, cmd, temp_file_path, "Command timed out")
    except Exception as e:
        error_msg = f"Error executing command: {str(e)}"
        with open(temp_file_path, 'a') as f:
            f.write(f"\nERROR: {error_msg}\n")
        return (cmd_index, -1, cmd, temp_file_path, error_msg)


def print_progress(result: Tuple[int, int, str, str, str], verbose: int = 0):
    """
    Print progress of a command execution.
    
    Args:
        result: Tuple of (command_index, return_code, command, temp_file, error_msg)
        verbose: Verbosity level (0=quiet, 1=normal, 2=verbose)
    """
    cmd_index, return_code, cmd, temp_file, error_msg = result
    
    if verbose == 0:
        # Quiet mode - only print failures
        if return_code != 0:
            print(f"{Colors.RED}FAILED{Colors.RESET} [#{cmd_index + 1}] [Exit: {return_code}] {cmd}")
            if error_msg:
                print(f"  Error: {error_msg}")
    else:
        # Normal or verbose mode
        if return_code == 0:
            status = f"{Colors.GREEN}SUCCESS{Colors.RESET}"
        else:
            status = f"{Colors.RED}FAILED{Colors.RESET}"
        
        print(f"{status} [#{cmd_index + 1}] [Exit: {return_code}] {cmd}")
        if error_msg:
            print(f"  {Colors.YELLOW}Error:{Colors.RESET} {error_msg}")
        
        # In verbose mode, show temp file location
        if verbose >= 2:
            print(f"  {Colors.CYAN}Log:{Colors.RESET} {temp_file}")


def load_commands(file_path: str) -> list:
    """
    Load commands from a file.
    
    Args:
        file_path: Path to the commands file
        
    Returns:
        List of command strings
    """
    try:
        with open(file_path, 'r') as f:
            commands = [line.strip() for line in f if line.strip() and not line.strip().startswith('#')]
        return commands
    except FileNotFoundError:
        print(f"Error: Command file '{file_path}' not found", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"Error reading command file: {str(e)}", file=sys.stderr)
        sys.exit(1)


def main():
    parser = argparse.ArgumentParser(
        description='Execute commands from a file in parallel (GNU parallel-like)',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s commands.txt
  %(prog)s commands.txt -j 16
  %(prog)s commands.txt -j 64 -v
  %(prog)s commands.txt --dry-run
        """
    )
    
    parser.add_argument(
        'command_file',
        help='File containing commands to execute (one per line)'
    )
    
    parser.add_argument(
        '-j', '--jobs',
        type=int,
        default=32,
        help='Number of parallel jobs (default: 32)'
    )
    
    parser.add_argument(
        '-v', '--verbose',
        action='count',
        default=1,
        help='Increase verbosity (can be used multiple times: -v, -vv)'
    )
    
    parser.add_argument(
        '-q', '--quiet',
        action='store_true',
        help='Quiet mode (only show failures and summary)'
    )
    
    parser.add_argument(
        '--no-color',
        action='store_true',
        help='Disable colored output'
    )
    
    parser.add_argument(
        '--dry-run',
        action='store_true',
        help='Print commands without executing them'
    )
    
    parser.add_argument(
        '--keep-order',
        action='store_true',
        help='Print results in the order commands were submitted'
    )
    
    parser.add_argument(
        '--halt-on-error',
        action='store_true',
        help='Stop execution if any command fails'
    )
    
    parser.add_argument(
        '-o', '--output',
        type=str,
        default='parallel_execution.log',
        help='Output log file for all commands (default: parallel_execution.log)'
    )
    
    parser.add_argument(
        '--keep-temp',
        action='store_true',
        help='Keep temporary files after execution'
    )
    
    parser.add_argument(
        '-s', '--serial-from',
        type=int,
        metavar='N',
        help='Execute commands serially starting from command number N (1-based index)'
    )
    
    parser.add_argument(
        '--range',
        type=str,
        metavar='START:END',
        help='Execute only commands in range START:END (1-based, inclusive). Examples: 5:10, :5, 10:'
    )
    
    args = parser.parse_args()
    
    # Handle verbosity settings
    if args.quiet:
        verbosity = 0
    else:
        verbosity = args.verbose
    
    # Disable colors if requested or if not a TTY
    if args.no_color or not sys.stdout.isatty():
        Colors.disable()
    
    # Validate number of jobs
    if args.jobs < 1:
        print("Error: Number of jobs must be at least 1", file=sys.stderr)
        sys.exit(1)
    
    # Validate serial-from argument
    if args.serial_from is not None and args.serial_from < 1:
        print("Error: Serial command number must be at least 1", file=sys.stderr)
        sys.exit(1)
    
    # Parse and validate range argument
    range_start = None
    range_end = None
    if args.range:
        try:
            parts = args.range.split(':')
            if len(parts) != 2:
                raise ValueError("Range must be in format START:END")
            
            # Parse start (empty means from beginning)
            if parts[0].strip():
                range_start = int(parts[0].strip())
                if range_start < 1:
                    raise ValueError("Range start must be at least 1")
            else:
                range_start = 1
            
            # Parse end (empty means to end)
            if parts[1].strip():
                range_end = int(parts[1].strip())
                if range_end < 1:
                    raise ValueError("Range end must be at least 1")
            else:
                range_end = None  # Will be set to total commands later
            
            # Validate start <= end
            if range_end is not None and range_start > range_end:
                raise ValueError("Range start must be less than or equal to end")
                
        except ValueError as e:
            print(f"Error: Invalid range format: {e}", file=sys.stderr)
            print("Use format: START:END (e.g., 5:10, :5, 10:)", file=sys.stderr)
            sys.exit(1)
    
    # Load commands
    commands = load_commands(args.command_file)
    
    if not commands:
        print("No commands found in file", file=sys.stderr)
        sys.exit(1)
    
    # Apply range filter if specified
    original_count = len(commands)
    if args.range:
        # Set range_end to total commands if not specified
        if range_end is None:
            range_end = len(commands)
        
        # Validate range against actual command count
        if range_start > len(commands):
            print(f"Error: Range start {range_start} exceeds total commands {len(commands)}", file=sys.stderr)
            sys.exit(1)
        
        if range_end > len(commands):
            range_end = len(commands)
        
        # Filter commands (convert to 0-based indexing)
        commands = commands[range_start - 1:range_end]
        
        if verbosity >= 1:
            print(f"{Colors.BOLD}Loaded {original_count} command(s) from '{args.command_file}'{Colors.RESET}")
            print(f"{Colors.CYAN}Executing range {range_start}:{range_end} ({len(commands)} command(s)){Colors.RESET}")
    else:
        if verbosity >= 1:
            print(f"{Colors.BOLD}Loaded {len(commands)} command(s) from '{args.command_file}'{Colors.RESET}")
    
    if not commands:
        print("No commands in specified range", file=sys.stderr)
        sys.exit(1)
    
    if verbosity >= 1:
        if args.serial_from and args.serial_from <= len(commands):
            if args.serial_from == 1:
                print(f"{Colors.BOLD}Executing all commands serially{Colors.RESET}\n")
            else:
                print(f"{Colors.BOLD}Executing commands 1-{args.serial_from - 1} in parallel ({args.jobs} jobs){Colors.RESET}")
                print(f"{Colors.BOLD}Executing commands {args.serial_from}-{len(commands)} serially{Colors.RESET}\n")
        else:
            print(f"{Colors.BOLD}Executing with {args.jobs} parallel job(s){Colors.RESET}\n")
    
    # Dry run mode
    if args.dry_run:
        print("DRY RUN - Commands to be executed:")
        for i, cmd in enumerate(commands, 1):
            print(f"  {i}. {cmd}")
        return
    
    # Create temporary directory for command outputs
    temp_dir = tempfile.mkdtemp(prefix='parallel_exec_')
    if verbosity >= 2:
        print(f"{Colors.CYAN}Using temporary directory:{Colors.RESET} {temp_dir}\n")
    
    # Calculate the offset for command numbering (when using range)
    cmd_offset = (range_start - 1) if args.range else 0
    
    # Execute commands in parallel
    start_time = time.time()
    failed_count = 0
    success_count = 0
    all_results = []
    
    try:
        # Determine split point for parallel vs serial execution
        serial_from_index = None
        if args.serial_from:
            serial_from_index = args.serial_from - 1  # Convert to 0-based index
            if serial_from_index >= len(commands):
                serial_from_index = None  # All commands run in parallel
        
        # Split commands into parallel and serial batches
        if serial_from_index is not None and serial_from_index > 0:
            parallel_commands = commands[:serial_from_index]
            serial_commands = commands[serial_from_index:]
        elif serial_from_index == 0:
            # All commands run serially
            parallel_commands = []
            serial_commands = commands
        else:
            # All commands run in parallel
            parallel_commands = commands
            serial_commands = []
        
        # Execute parallel batch
        if parallel_commands:
            if verbosity >= 1 and serial_commands:
                print(f"{Colors.CYAN}=== Executing parallel batch ({len(parallel_commands)} commands) ==={Colors.RESET}\n")
            
            cmd_args = [(i + cmd_offset, cmd, temp_dir) for i, cmd in enumerate(parallel_commands)]
            
            with Pool(processes=args.jobs) as pool:
                if args.keep_order:
                    results = pool.map(execute_command, cmd_args)
                else:
                    results = pool.imap_unordered(execute_command, cmd_args)
                
                for result in results:
                    all_results.append(result)
                    print_progress(result, verbosity)
                    
                    if result[1] == 0:
                        success_count += 1
                    else:
                        failed_count += 1
                        if args.halt_on_error:
                            print(f"\n{Colors.RED}Halting execution due to error{Colors.RESET}", file=sys.stderr)
                            pool.terminate()
                            serial_commands = []  # Skip serial execution
                            break
        
        # Execute serial batch
        if serial_commands:
            if verbosity >= 1 and parallel_commands:
                print(f"\n{Colors.CYAN}=== Executing serial batch ({len(serial_commands)} commands) ==={Colors.RESET}\n")
            
            for i, cmd in enumerate(serial_commands):
                cmd_index = len(parallel_commands) + i + cmd_offset
                result = execute_command((cmd_index, cmd, temp_dir))
                all_results.append(result)
                print_progress(result, verbosity)
                
                if result[1] == 0:
                    success_count += 1
                else:
                    failed_count += 1
                    if args.halt_on_error:
                        print(f"\n{Colors.RED}Halting execution due to error{Colors.RESET}", file=sys.stderr)
                        break
    
    except KeyboardInterrupt:
        print(f"\n\n{Colors.YELLOW}Interrupted by user{Colors.RESET}", file=sys.stderr)
        sys.exit(130)
    
    finally:
        # Sort results by command index to maintain order
        all_results.sort(key=lambda x: x[0])
        
        try:
            with open(args.output, 'w') as outfile:
                # Write header
                outfile.write(f"{'#'*70}\n")
                outfile.write(f"# Parallel Execution Log\n")
                outfile.write(f"# Generated: {time.strftime('%Y-%m-%d %H:%M:%S')}\n")
                outfile.write(f"# Total Commands: {len(commands)}\n")
                outfile.write(f"# Parallel Jobs: {args.jobs}\n")
                if args.range:
                    outfile.write(f"# Command range: {args.range}\n")
                if args.serial_from:
                    outfile.write(f"# Serial execution from command: {args.serial_from}\n")
                outfile.write(f"{'#'*70}\n\n")
                
                # Concatenate each command's output
                for cmd_index, return_code, cmd, temp_file, error_msg in all_results:
                    if os.path.exists(temp_file):
                        with open(temp_file, 'r') as infile:
                            outfile.write(infile.read())
                
                # Write summary
                elapsed_time = time.time() - start_time
                outfile.write(f"\n{'#'*70}\n")
                outfile.write(f"# Execution Summary\n")
                outfile.write(f"{'#'*70}\n")
                if args.range:
                    outfile.write(f"Total commands in file: {original_count}\n")
                    outfile.write(f"Commands in range: {len(commands)}\n")
                else:
                    outfile.write(f"Total commands: {len(commands)}\n")
                outfile.write(f"Executed: {len(all_results)}\n")
                outfile.write(f"Successful: {success_count}\n")
                outfile.write(f"Failed: {failed_count}\n")
                outfile.write(f"Elapsed time: {elapsed_time:.2f} seconds\n")
                outfile.write(f"{'#'*70}\n")
            
        except Exception as e:
            print(f"Error writing log file: {str(e)}", file=sys.stderr)
        
        # Clean up temporary files unless --keep-temp is specified
        if not args.keep_temp:
            try:
                import shutil
                shutil.rmtree(temp_dir)
                if verbosity >= 2:
                    print(f"{Colors.GREEN}SUCCESS{Colors.RESET} Cleaned up temporary directory")
            except Exception as e:
                print(f"{Colors.YELLOW}Warning:{Colors.RESET} Could not remove temporary directory: {str(e)}", file=sys.stderr)
        else:
            if verbosity >= 1:
                print(f"{Colors.CYAN}INFO{Colors.RESET} Temporary files kept in: {temp_dir}")
    
    # Print summary
    elapsed_time = time.time() - start_time
    total_count = success_count + failed_count
    
    print(f"\n{'='*60}")
    print(f"{Colors.BOLD}Execution Summary:{Colors.RESET}")
    print(f"  Total commands: {len(commands)}")
    print(f"  Executed: {total_count}")
    print(f"  {Colors.GREEN}Successful:{Colors.RESET} {success_count}")
    if failed_count > 0:
        print(f"  {Colors.RED}Failed:{Colors.RESET} {failed_count}")
    else:
        print(f"  Failed: {failed_count}")
    print(f"  Elapsed time: {elapsed_time:.2f} seconds")
    if verbosity >= 1:
        print(f"  Log file: {args.output}")
    print(f"{'='*60}")
    
    # Exit with error code if any command failed
    if failed_count > 0:
        sys.exit(1)


if __name__ == '__main__':
    main()
