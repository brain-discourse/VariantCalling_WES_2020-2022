#!/bin/bash
# Usage: bash rename_files.sh
# Renames *_final_output.txt files to *.txt.

for i in *_final_output.txt; do
    n="${i%_final_output.txt}"
    mv "$i" "$n.txt"
done