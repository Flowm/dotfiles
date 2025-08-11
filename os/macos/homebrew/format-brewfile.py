#!/usr/bin/env python3
"""
Format Brewfile to have descriptions as inline comments with tool name prefixes.

Converts from:
    # Description text
    brew "package"
To:
    brew "package"                                # package: Description text
"""

import re
import sys

def format_brewfile(filename):
    # Regex patterns
    comment_pattern = re.compile(r'^#\s*(.+)$')
    package_pattern = re.compile(r'^(brew|cask)\s+"([^"]+)"')

    with open(filename, 'r') as f:
        lines = [line.rstrip() for line in f.readlines()]

    result = []
    i = 0

    while i < len(lines):
        line = lines[i]

        # Check if current line is a description comment
        comment_match = comment_pattern.match(line)

        if (comment_match and i + 1 < len(lines) and package_pattern.match(lines[i + 1])):
            description = comment_match.group(1)
            package_line = lines[i + 1]

            # Extract tool name
            tool_match = package_pattern.match(package_line)
            tool_name = tool_match.group(2) if tool_match else "unknown"

            # Format with consistent spacing
            formatted_line = f"{package_line:<48}  # {tool_name}: {description}"

            result.append(formatted_line)
            i += 2  # Skip both lines
        else:
            # Keep line as-is (taps, standalone comments, etc.)
            if line or i == 0:
                result.append(line)
            i += 1

    # Write back to file
    with open(filename, 'w') as f:
        f.write('\n'.join(result) + '\n')

if __name__ == "__main__":
    filename = sys.argv[1] if len(sys.argv) > 1 else "Brewfile"
    format_brewfile(filename)
