#!/bin/bash
#SBATCH -t 07-00:00:00
#SBATCH --mem=20g
#SBATCH -J annovar_annot
#SBATCH --output=full_annot_%j.out

module load gatk/4.1.7.0 
module load samtools/1.11
module load annovar/20200609
module load r/3.6.0



DIR=/proj/heinzenlab/users/meethila1/brain_only
HUMANDB=/proj/heinzenlab/users/meethila1/humandb
SAMPLES=$DIR/mutect_filtered_samplelist.txt #txt file containing all sample names for annotation

# BED files
BED1=hg38_CCDSexons+2bp.CCDSv22.bed
BED2=hg38_JEME_db_final.txt
BED3=hg38_links_db_final.txt

for SAMPLE in $(cat "$SAMPLES"); do

  VCF_INPUT="$DIR/${SAMPLE}_somatic_filtered.vcf"
  VCF_UID="$DIR/${SAMPLE}_somatic_filtered.UID"
  VCF_TABLE_OUT="$DIR/${SAMPLE}_somatic_filtered.vcf.table"
  AVINPUT="$DIR/${SAMPLE}_somatic_filtered.avinput"
  AVOUTPUT="$DIR/${SAMPLE}_somatic_filtered.annotated"
  FINAL_OUT="$DIR/${SAMPLE}_final_annotated_merged.tsv"

  # ------------------ STEP 1: Generate Unique Identifier ------------------
  bcftools annotate --set-id +'%CHROM:%POS:%REF:%FIRST_ALT' "$VCF_INPUT" > "$VCF_UID"
  
  # ------------------ STEP 2: VCF to table  ------------------
  
  gatk VariantsToTable -V "$VCF_UID" --show-filtered -O "$VCF_TABLE_OUT"
  
  # ------------------ STEP 3: Generate annovar input file  ------------------
  
  convert2annovar.pl -format vcf4 "$VCF_UID" -outfile "$AVINPUT" \
  -allsample -includeinfo -withfreq 
  
  # ------------------ STEP 4: Region based annotation  ------------------
  
  #for CCDS exons in refseq region plus 2 bps splicing 
  annotate_variation.pl "$AVINPUT" "$HUMANDB" \
  -bedfile "$BED1" -dbtype bed -regionanno -colsWanted all \
  -out "$DIR/${SAMPLE}_filtered.ccds"
  
  #for JEME regulatory regions; ref :Roadmap Epigenomics Consortium., Kundaje, A., Meuleman, W. et al. Integrative analysis of 111 reference human epigenomes. Nature 518, 317–330 (2015). https://doi.org/10.1038/nature14248
  annotate_variation.pl "$AVINPUT" "$HUMANDB" \
  -bedfile "$BED2" -buildver hg38 -dbtype bed -regionanno -colsWanted all \
  -out "$DIR/${SAMPLE}_filtered.jeme"
  
  #for LINCS regulatory regions; ref :Roadmap Epigenomics Consortium., Kundaje, A., Meuleman, W. et al. Integrative analysis of 111 reference human epigenomes. Nature 518, 317–330 (2015). https://doi.org/10.1038/nature14248
  annotate_variation.pl "$AVINPUT" "$HUMANDB" \
  -bedfile "$BED3" -buildver hg38 -dbtype bed -regionanno -colsWanted all \
  -out "$DIR/${SAMPLE}_filtered.lincs"

  echo "****Region based annotation  complete****" \

# ------------------ STEP 5: Filter based annotation  ------------------
  table_annovar.pl "$VCF_UID" "$HUMANDB" \
  -buildver hg38 -out "$AVOUTPUT" \
  -remove \
  -protocol refGene,cytoBand,gnomad211_exome,gnomad211_genome,gene4denovo201907,exac03,intervar_20180118,dbscsnv11,avsnp150,kaviar_20150923,dbnsfp41a,dbnsfp30a,revel,ljb26_all,regsnpintron,clinvar_20200316,kaplanis_v1,VKGL,cosmic92_coding,cosmic92_noncoding \
  -operation g,r,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f \
  -nastring . \
  -vcfinput \

# ------------------ STEP 6: Merge all annotation outputs  ------------------
Rscript - <<EOF
    library(readr)
    library(dplyr)
    
    cat("Merging annotations for: $SAMPLE\n")

    #read output files and merge by UID
    
    Macro1 <- read_tsv("$VCF_TABLE_OUT", show_col_types = FALSE)
    Macro2 <- read_tsv("${AVOUTPUT}.hg38_multianno.txt", show_col_types = FALSE)
    
    bed_list <- list(
      read_tsv("${DIR}/${SAMPLE}_filtered.ccds.hg38_bed", show_col_types = FALSE),
      read_tsv("${DIR}/${SAMPLE}_filtered.jeme.hg38_bed", show_col_types = FALSE),
      read_tsv("${DIR}/${SAMPLE}_filtered.lincs.hg38_bed", show_col_types = FALSE)
    )
    
    bed_list <- lapply(bed_list, function(df) {
      df %>%
        dplyr::select(1, 2, 3, 4, 5, 6, 7, 8, 10, 13) %>%
        dplyr::rename(Bed_0 = 1, Bed_annotation = 2, Bed_Chr = 3, Bed_Start = 4, Bed_End = 5,
                      Bed_Ref = 6, Bed_Alt = 7, Bed_1 = 8, Bed_2 = 9, ID = 10)
    })
    
    bed_merged <- bind_rows(bed_list)
    
    vcf_bed_merged <- left_join(Macro1, bed_merged, by = "ID")

    # add additional annotations
    
    ddg2p <- read_tsv("/proj/heinzenlab/users/meethila1/humandb/hg38_DDG2P_15_11_2020.txt", show_col_types = FALSE)
    lof_metrics <- read_tsv("/proj/heinzenlab/users/meethila1/humandb/hg38_gnomad_lof_metrics.txt", show_col_types = FALSE)
    lof_tool <- read_tsv("/proj/heinzenlab/users/meethila1/humandb/hg38_LoFtool_scores.txt", show_col_types = FALSE)
    
    annout1 <- left_join(Macro2, lof_tool, by = "Gene.refGene")
    annout2 <- left_join(annout1, ddg2p, by = "Gene.refGene")
    annout3 <- left_join(annout2, lof_metrics, by = "Gene.refGene")
    
    annout3 <- annout3 %>%
      rename(ID = names(annout3)[which(sapply(annout3, function(x) all(grepl("^chr[0-9XYM]+:[0-9]+:[ACGT]+:[ACGT]+$", x) | is.na(x))) )])
    
    final_out <- left_join(annout3, vcf_bed_merged, by = "ID")
    
    write_tsv(final_out, "$FINAL_OUT")
    cat("Merged output written to $FINAL_OUT\n")
EOF

  echo "Completed sample: $SAMPLE"

done
