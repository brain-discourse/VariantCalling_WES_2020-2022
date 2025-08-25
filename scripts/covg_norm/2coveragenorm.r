# 2coveragenorm.r
# Usage: Rscript 2coveragenorm.r
# Description: Filters and normalizes coverage matrices for cases and controls.

library(data.table)
library(readr)
library(dplyr)
library(tidyr)

# ----------- CONFIGURATION -----------
input_file <- "/overflow/heinzenlab/dbgap-NABEC/coverage/site_matrix_Xchr1.txt"

# ----------- FUNCTIONS -----------

# Filter matrix by minimum coverage threshold
filter_matrix <- function(df, colnames, min_cov) {
  df %>%
    mutate(across(all_of(colnames), ~replace(.x, .x < min_cov, NA)))
}

# Write matrix to file
write_matrix <- function(df, out_path) {
  write_tsv(df, out_path)
}

# ----------- MAIN SCRIPT -----------

site_matrix <- read.table(input_file, header = TRUE, sep = "\t", stringsAsFactors = FALSE, skip = 1) # nolint: line_length_linter.

# Controls: Males
controls_male_cols <- c(
  "Depth_for_SH.00.38_combined", "Depth_for_SH.01.31", "Depth_for_SH.03.28_combined", "Depth_for_SH.04.19_combined",
  "Depth_for_SH.95.21_combined", "Depth_for_UMARY.1104_combined", "Depth_for_UMARY.1259", "Depth_for_UMARY.1274",
  "Depth_for_UMARY.1277", "Depth_for_UMARY.1441", "Depth_for_UMARY.1461", "Depth_for_UMARY.1464", "Depth_for_UMARY.1583_combined",
  "Depth_for_UMARY.1668_combined", "Depth_for_UMARY.1675", "Depth_for_UMARY.1831", "Depth_for_UMARY.1841", "Depth_for_UMARY.1847_combined",
  "Depth_for_UMARY.1859", "Depth_for_UMARY.1861", "Depth_for_UMARY.1866_combined", "Depth_for_UMARY.1935_combined", "Depth_for_UMARY.1936",
  "Depth_for_UMARY.260", "Depth_for_UMARY.290", "Depth_for_UMARY.4549_combined", "Depth_for_UMARY.4590_combined", "Depth_for_UMARY.4598_combined",
  "Depth_for_UMARY.4781", "Depth_for_UMARY.5087_combined", "Depth_for_UMARY.5088", "Depth_for_UMARY.5089_combined", "Depth_for_UMARY.5114",
  "Depth_for_UMARY.5116", "Depth_for_UMARY.5123", "Depth_for_UMARY.5179", "Depth_for_1465_1024.pfc.bulk", "Depth_for_UMB1024.pfc.1b12",
  "Depth_for_UMB1474.pfc.1b123", "Depth_for_UMB1712.pfc.1b12", "Depth_for_UMB4672.pfc.1b12_200x", "Depth_for_UMB4842.pfc.1b1",
  "Depth_for_UMB5238.pfc.1b123", "Depth_for_UMB5391.pfc.1b12", "Depth_for_UMB818.pfc.1b1", "Depth_for_UMB914.pfc.1b12"
)
controls_matrix_males <- site_matrix %>% select(Locus, all_of(controls_male_cols))
controls_matrix_males <- filter_matrix(controls_matrix_males, controls_male_cols, 25)
write_matrix(controls_matrix_males, "/overflow/heinzenlab/dbgap-NABEC/coverage/coverage_normalized_control_matrix_no_index_males")

# Controls: Females
controls_female_cols <- c(
  "Depth_for_SH.01.37_combined", "Depth_for_SH.02.06_combined", "Depth_for_SH.04.05_combined", "Depth_for_UMARY.1209_combined", # nolint
  "Depth_for_UMARY.1379", "Depth_for_UMARY.1455", "Depth_for_UMARY.1539", "Depth_for_UMARY.1710_combined", "Depth_for_UMARY.4640_combined",
  "Depth_for_UMARY.4976", "Depth_for_UMARY.5120", "Depth_for_UMARY.794_combined", "Depth_for_UMB1499.pfc.1b1", "Depth_for_UMB4548.pfc.1b1",
  "Depth_for_UMB5161.pfc.1b1", "Depth_for_4638_1024.pfc.bulk", "Depth_for_4643_1024.pfc.bulk"
)
controls_matrix_females <- site_matrix %>% select(Locus, all_of(controls_female_cols)) # nolint: line_length_linter.
controls_matrix_females <- filter_matrix(controls_matrix_females, controls_female_cols, 50)
write_matrix(controls_matrix_females, "/overflow/heinzenlab/dbgap-NABEC/coverage/coverage_normalized_control_matrix_no_index_females")

#


