######################################Filter rows by pass and CCDS######################################
#This script filters VCF files to only include rows that have "PASS" in the FILTER
#!/bin/bash
# Usage: bash filter_pass_ccds.sh input.txt output.txt
# Filters rows where column 343 is "PASS" and column 373 is "bed".

awk -F "\t" 'NR==1; NR > 1 { if(($343 == "PASS") && ($373 == "bed")) { print } }' "$1" > "$2"



######################################Filter rows by gene######################################
#This script filters VCF files to only include rows that have a specific gene in column 7
#!/bin/bash
# Usage: bash filter_gene.sh input.txt output.txt gene_name
# Filters rows where column 3 matches the specified gene name.

awk -F "\t" -v gene="$3" 'NR==1; NR > 1 { if($3 == gene) { print } }' "$1" > "$2"