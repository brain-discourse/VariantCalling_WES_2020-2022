#!/bin/bash
# Usage: bash count_lines.sh
# Counts lines in all files matching *output.txt.

find . -name '*output.txt' | xargs wc -l