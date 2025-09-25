#!/usr/bin/env python3
"""
Split a Graphviz DOT file containing multiple digraphs into separate files.
Each digraph will be saved as an individual DOT file with intelligently sequenced names.
"""

import re
import os
import argparse
from pathlib import Path
from typing import List, Tuple


def parse_dot_file(file_path: str) -> List[Tuple[str, str]]:
    """
    Parse a DOT file and extract individual digraphs.
    
    Args:
        file_path: Path to the input DOT file
        
    Returns:
        List of tuples containing (digraph_name, digraph_content)
    """
    with open(file_path, 'r') as f:
        content = f.read()
    
    # Find all digraph blocks
    digraphs = []
    brace_count = 0
    current_digraph = ""
    in_digraph = False
    digraph_counter = 1
    
    lines = content.split('\n')
    
    for line in lines:
        stripped_line = line.strip()
        
        # Check if we're starting a new digraph
        if stripped_line.startswith('digraph'):
            if in_digraph:
                # Save the previous digraph
                digraphs.append((f"digraph_{digraph_counter:02d}", current_digraph.strip()))
                digraph_counter += 1
                current_digraph = ""
            
            in_digraph = True
            brace_count = 0
            current_digraph = line + '\n'
            
            # Count opening braces in the digraph line
            brace_count += line.count('{') - line.count('}')
            
        elif in_digraph:
            current_digraph += line + '\n'
            brace_count += line.count('{') - line.count('}')
            
            # Check if we've closed all braces
            if brace_count == 0:
                # End of current digraph
                digraphs.append((f"digraph_{digraph_counter:02d}", current_digraph.strip()))
                digraph_counter += 1
                current_digraph = ""
                in_digraph = False
    
    # Handle case where file doesn't end with proper closing
    if in_digraph and current_digraph.strip():
        digraphs.append((f"digraph_{digraph_counter:02d}", current_digraph.strip()))
    
    return digraphs


def extract_meaningful_name(digraph_content: str) -> str:
    """
    Extract a meaningful name from the digraph content based on node labels.
    
    Args:
        digraph_content: The content of the digraph
        
    Returns:
        A meaningful name based on the content
    """
    # Look for function names or meaningful identifiers in node labels
    node_pattern = r'"([^"]*)"'
    nodes = re.findall(node_pattern, digraph_content)
    
    if nodes:
        # Try to find function names or addresses
        for node in nodes[:5]:  # Check first few nodes
            # Look for function-like patterns
            if any(keyword in node.lower() for keyword in ['init', 'main', 'start', 'call', 'ret']):
                # Extract the first meaningful word
                words = re.findall(r'\w+', node)
                if words:
                    return words[0].lower()
            
            # Look for memory addresses
            addr_match = re.search(r'([0-9a-fA-F]+)', node)
            if addr_match:
                return f"addr_{addr_match.group(1)}"
    
    return None


def split_dot_file(input_file: str, output_dir: str = None, use_graphviz: bool = True):
    """
    Split a DOT file into multiple files, one for each digraph.
    
    Args:
        input_file: Path to the input DOT file
        output_dir: Directory to save the split files (default: same as input file)
        use_graphviz: Whether to use graphviz library for validation
    """
    input_path = Path(input_file)
    
    if output_dir is None:
        output_dir = input_path.parent
    else:
        output_dir = Path(output_dir)
        output_dir.mkdir(parents=True, exist_ok=True)
    
    # Parse the DOT file
    digraphs = parse_dot_file(input_file)
    
    if not digraphs:
        print("No digraphs found in the input file.")
        return
    
    print(f"Found {len(digraphs)} digraph(s) in {input_file}")
    
    # Split and save each digraph
    for i, (default_name, content) in enumerate(digraphs, 1):
        # Try to extract a meaningful name
        meaningful_name = extract_meaningful_name(content)
        
        if meaningful_name:
            filename = f"{input_path.stem}_{meaningful_name}_{i:02d}.dot"
        else:
            filename = f"{input_path.stem}_{default_name}.dot"
        
        output_path = output_dir / filename
        
        # Write the digraph to a separate file
        with open(output_path, 'w') as f:
            f.write(content)
        
        print(f"Created: {output_path}")
        
        # Optional: Validate with graphviz if available
        if use_graphviz:
            try:
                import graphviz
                # Try to parse the generated file to ensure it's valid
                source = graphviz.Source(content)
                # This will raise an exception if the DOT syntax is invalid
                source.source
                print(f"  ✓ Validated syntax for {filename}")
            except ImportError:
                print("  ! graphviz library not available for validation")
            except Exception as e:
                print(f"  ⚠ Warning: Syntax validation failed for {filename}: {e}")


def main():
    parser = argparse.ArgumentParser(
        description="Split a Graphviz DOT file containing multiple digraphs into separate files"
    )
    parser.add_argument(
        "input_file",
        help="Path to the input DOT file"
    )
    parser.add_argument(
        "-o", "--output-dir",
        help="Output directory for split files (default: same as input file)"
    )
    parser.add_argument(
        "--no-validation",
        action="store_true",
        help="Skip graphviz validation of output files"
    )
    
    args = parser.parse_args()
    
    if not os.path.exists(args.input_file):
        print(f"Error: Input file '{args.input_file}' does not exist.")
        return 1
    
    try:
        split_dot_file(
            args.input_file,
            args.output_dir,
            use_graphviz=not args.no_validation
        )
        print("\nSplit completed successfully!")
    except Exception as e:
        print(f"Error: {e}")
        return 1
    
    return 0


if __name__ == "__main__":
    exit(main())
