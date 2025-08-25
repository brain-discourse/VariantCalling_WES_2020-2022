#################### to mergefiles with common headers###################
#!/bin/bash
# Usage: bash merge_files_with_headers.sh
# Merges .txt files with the same headers, skipping headers after the first file.

awk 'FNR==1 && NR!=1{next;} {print}' *.txt > merged.txt


################### to mergefiles without headers#######################
#!/bin/bash
# Usage: bash merge_files_no_headers.sh
# Concatenates all .txt files (no headers) into one file.

cat *.txt > merged.txt