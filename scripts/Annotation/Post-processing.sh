#!/bin/bash
#SBATCH -N 1
#SBATCH -t 07-00:00:00
#SBATCH --mem=80g
#SBATCH -J post_process
#SBATCH --output=post_process_%j.out

module load r/3.6.0

# ---------- STEP 1: Add sample identifier ----------
echo "Add filename to each file"

for i in *_final_annotated_merged.tsv; do
  awk -v fname="$i" '{print fname "\t" $0}' "$i" > "$i.tmp" && mv "$i.tmp" "$i"
done

# ---------- STEP 2: Merge annotation files  ----------

echo "Merging files with identical headers"

#get header from first file
  head -n 1 *_final_annotated_merged.tsv | head -n 1 > all_annotated_and_merged_final.txt

#Append all files 

  for file in *_final_annotated_merged.tsv; do
    tail -n +2 "$file" >> all_annotated_and_merged_final.txt
  done

# ---------- STEP 3: Check line counts  ----------

echo "Checking line counts"

find . -name '*_final_annotated_merged.tsv' | xargs wc -l
wc -l all_annotated_and_merged_final.txt


# ---------- STEP 4: Filtering (Optional)  ----------

echo "Filtering for PASS and CCDS annotations"
awk -F "\t" '
NR==1 {
  for (i=1; i<=NF; i++) {
awk -F "\t" '
NR==1 {
  for(i=1;i<=NF;i++) {
    if($i=="Gene.refGene") gene_col=i
  }
  print
  next
}
NR>1 {
  if(gene_col && $gene_col=="AKT3") print
}
' all_annotated_and_merged_final.txt > all_annotated_and_merged_filtered_AKT3.txt
    if ($i == "Bed_Name") bed_col=i;
  }
  print;
  next;
}
echo "Formatting merged table using R for brain_only"
  if (($filter_col == "PASS") && ($bed_col == "bed")) print;
}
' all_annotated_and_merged_final.txt > all_annotated_and_merged_final_PASS_CCDS.txt

echo "Filtering for specific genes (e.g., AKT3)"
awk -F "\t" 'NR==1; NR > 1 { if($3 == "AKT3") { print } }' all_annotated_and_merged_final.txt > all_annotated_and_merged_filtered_AKT3.txt


# ---------- STEP 5: Formatting (Optional) - demo script ----------

echo "📊 Formatting merged table using R for brain_only"

Rscript - <<EOF
library(readr)
library(dplyr)
samples <- c("AKT3","BRAF", "DEPDC5", "NIPBL", "PIK3CA", "RANBP2", "SLC35A2", "STXBP1", "TSC2", "ARID1A", "CASK", "CUL1", "KRAS", "MTOR", "PLNXB1","SCN1A", "SOS2", "TSC1", "YWHAH")
for (f in samples) {
  path <- "/proj/heinzenlab/users/meethila1/brain_only/brain_only_annotated/merged_tables/"
  infile <- paste0(path, f, ".txt")
  outfile <- paste0(path, f, "_edited.txt")
  df <- read_tsv(infile, show_col_types = FALSE)
  edited <- df %>%
    select("sample_name","ID","Gene.refGene","Chr","Start","End","Ref","Alt",
           "Func.refGene","GeneDetail.refGene","ExonicFunc.refGene","AAChange.refGene",
           "cytoBand","gnomad_exome_AF","gnomad_exome_non_topmed_AF_popmax",
           "gnomad_exome_non_neuro_AF_popmax","gnomad_exome_non_cancer_AF_popmax",
           "gnomad_exome_controls_AF_popmax","gnomad_genome_AF","gnomad_genome_AF_popmax",
           "gnomad_genome_non_topmed_AF_popmax","gnomad_genome_non_neuro_AF_popmax",
           "gnomad_genome_non_cancer_AF_popmax","gnomad_genome_controls_AF_popmax",
           "gene4denovo_DN_ID","ExAC_ALL","InterVar_automated","dbscSNV_ADA_SCORE",
           "dbscSNV_RF_SCORE","avsnp150","Kaviar_AF","Kaviar_AC","Kaviar_AN",
           "SIFT4G_pred","Polyphen2_HDIV_pred","Polyphen2_HVAR_pred","MutationAssessor_pred",
           "VEST4_score","REVEL_score","CADD_phred","Interpro_domain","GTEx_V8_gene",
           "GTEx_V8_tissue","SIFT_score","regsnp_fpr","regsnp_disease","regsnp_splicing_site",
           "CLNALLELEID","CLNDN","CLNDISDB","CLNREVSTAT","CLNSIG","Kaplanis_consequence",
           "cosmic92_coding","cosmic92_noncoding","Otherinfo10","Otherinfo11","Otherinfo12",
           "Otherinfo13","LoFtool_percentile","gene mim","disease name","disease mim",
           "DDD category","allelic requirement","mutation consequence","phenotypes",
           "organ specificity list","pmids","panel","prev symbols","hgnc id",
           "gene disease pair entry date","transcript","pLI","oe_lof","mis_z",
           "CHROM","POS","REF","ALT","QUAL","FILTER","AS_FilterStatus","ECNT","DP",
           "AS_SB_TABLE","GERMQ","MBQ","MFRL","MMQ","MPOS","NALOD","NLOD","PON","POPAF",
           "ROQ","RPA","RU","STR","STRQ","TLOD","vcf_GT","vcf_AD","vcf_AF","vcf_DP",
           "vcf_F1R2","vcf_F2R1","vcf_PGT","vcf_PID","vcf_PS","vcf_SB","Bed_Name") %>%
    rename(variant_ID = ID)
  write_tsv(edited, outfile)
}
EOF

echo "ALL DONE — Merged, cleaned, filtered, and formatted!"
