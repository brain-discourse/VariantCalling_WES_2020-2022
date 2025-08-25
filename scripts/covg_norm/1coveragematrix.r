# 1coveragematrix.r
# Usage: Rscript 1coveragematrix.r
# Description: Combines GATK coverage-by-base outputs into a matrix (rows: sites, columns: samples).

library(readr)
library(dplyr)
library(tidyr)
library(data.table)

# ----------- CONFIGURATION -----------
coverage_dirs <- c(
  "/proj/heinzenlab/projects/somaticNov2020/coverage/UMB1474-pfc-1b123/",
  "/proj/heinzenlab/projects/somaticNov2020/coverage/UMB1499-pfc-1b1/",
  # ... add all other directories here ...
  "/overflow/heinzenlab/dbgap-NABEC/coverage/UMARY-914/"
)
file_pattern <- "coverage$" # pattern to match coverage files

# ----------- FUNCTIONS -----------

# List all coverage files in the given directories
get_coverage_files <- function(dirs, pattern) {
  files <- unlist(lapply(dirs, function(dir) {
    list.files(path = dir, pattern = pattern, full.names = TRUE)
  }))
  return(files)
}

# Read site identifiers from the first file
get_sites <- function(file) {
  sites <- read.table(file, header = FALSE, sep = ",")[, 1]
  return(sites)
}

# Read coverage values (column 4) from all files
get_coverage_matrix <- function(files) {
  coverage_list <- lapply(files, function(fn) {
    read.table(fn, header = FALSE, sep = ",")[, 4]
  })
  coverage_matrix <- do.call(cbind, coverage_list)
  return(coverage_matrix)
}

# Write output tables
write_outputs <- function(sites, coverage_matrix, out_prefix = "site_matrix") {
  df <- as.data.frame(cbind(sites, coverage_matrix))
  write.table(df, paste0(out_prefix, "_table.txt"), row.names = FALSE)
  write_tsv(df, paste0(out_prefix, ".txt"))
}

# ----------- MAIN SCRIPT -----------

main <- function() {
  files <- get_coverage_files(coverage_dirs, file_pattern)
  if (length(files) == 0) {
    stop("No coverage files found. Check your directories and pattern.")
  }
  sites <- get_sites(files[1])
  coverage_matrix <- get_coverage_matrix(files)
  write_outputs(sites, coverage_matrix)
}

main()