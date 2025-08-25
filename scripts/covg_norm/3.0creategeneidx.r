# 3.0creategeneidx.r
# Usage: Rscript 3.0creategeneidx.r
# Description: Creates a gene index file from refGene sites, adding locus positions and gene counts.

library(data.table)
library(dplyr)
library(tidyr)
library(readr)
library(rlang)

#--- CONFIGURATION ---
input_file <- "/overflow/heinzenlab/meethila/genes_db/hg38_refGene.txt"
temp_out <- "/overflow/heinzenlab/meethila/genes_db/genes_testing1"
final_out <- "/overflow/heinzenlab/meethila/genes_db/final_index_file"

#--- FUNCTIONS ---
unnest_dt <- function(tbl, col) {
  tbl <- as.data.table(tbl)
  colname <- deparse(substitute(col))
  tbl <- tbl[, .(position = unlist(get(colname))), by = setdiff(names(tbl), colname)]
  tbl
}

create_gene_index <- function(input_file, temp_out, final_out) {
  gene_sites <- read.table(input_file, header = TRUE, sep = '\t', stringsAsFactors = FALSE)
  genes_sites1 <- gene_sites %>%
    select(V1, V2, V3, V5) %>%
    unique() %>%
    rowwise() %>%
    mutate(lists = list(as.character(seq(from = as.numeric(V2), to = as.numeric(V3))))) %>%
    unnest(lists) %>%
    select(position = lists, V1, V5)
      lists = purrr::map2(
        as.numeric(V2),
        as.numeric(V3),
        ~ as.character(seq(from = .x, to = .y))
      )
    ) %>%
    unnest_dt(lists) %>%
    select(position = lists, V1, V5)
  setDT(genes_sites1)
  genes_sites1[, `:=` (count = .N), by = V5]
  write_tsv(genes_sites1, final_out)
}

#--- MAIN ---
create_gene_index(input_file, temp_out, final_out)
