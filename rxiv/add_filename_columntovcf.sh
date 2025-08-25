#!/bin/bash
# Usage: bash add_filename_column.sh
# Adds a column with the filename to every row in each .txt file in the current directory.

for i in *.txt; do
    awk '{print FILENAME"\t"$0}' "$i" > "$i.bk"
    mv "$i.bk" "$i"
done