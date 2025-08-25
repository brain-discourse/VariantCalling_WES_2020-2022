# Usage: Rscript format_columns_brain_only.R
library(readr)
library(dplyr)
library(tidyverse)

samples = c("AKT3","BRAF", "DEPDC5", "NIPBL", "PIK3CA", "RANBP2", "SLC35A2", "STXBP1", "TSC2", "ARID1A", "CASK", "CUL1" , "KRAS", "MTOR", "PLNXB1","SCN1A", "SOS2", "TSC1", "YWHAH") # nolint
for (f in samples) {
    my_csv = paste("/proj/heinzenlab/users/meethila1/brain_only/brain_only_annotated/merged_tables/", f, ".txt", sep = "") # nolint
    Outfile = paste("/proj/heinzenlab/users/meethila1/brain_only/brain_only_annotated/merged_tables/", f, "_edited.txt", sep = "") # nolint
    file_read <- read_tsv(my_csv)
    edited_csv <- file_read %>%
        # Replace column2, column3 with actual column names below # nolint
        rename(variant_ID = ID)
            select(ID, actual_column2, actual_column3) %>% # nolint
            rename(variant_ID = "ID") # nolint: indentation_linter.
    write_tsv(edited_csv, Outfile)
}

#Note: Repeat similarly for brain_blood and paired sample scripts, adjusting column names and sample lists as needed. # nolint