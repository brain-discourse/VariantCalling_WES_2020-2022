#!/bin/bash
# Usage: bash add_header_to_file.sh file_with_headers file_to_edit
# Adds the header from file_with_headers to the top of file_to_edit.

header=$(head -n1 "$1")
sed -i '' "1s/^/$header\n/" "$2"