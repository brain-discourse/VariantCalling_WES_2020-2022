#!/bin/bash

module add samtools/1.11
module add biobambam2/2.0.168
module add bbmap
module add bwa/0.7.15
module add java
module add picard/2.21.7
module add gatk/4.1.7.0

INPUT_DIR=/proj/heinzenlab/projects/somaticNov2020/germline/
OUTPUT_DIR=/proj/heinzenlab/projects/somaticNov2020/germline/
REF=/proj/heinzenlab/projects/somaticNov2020/analysisfiles/GRCh38.d1.vd1.fa
KNOWN_SITES1=/proj/heinzenlab/projects/somaticNov2020/analysisfiles/resources-broad-hg38-v0-Homo_sapiens_assembly38.dbsnp138.vcf
KNOWN_SITES2=/proj/heinzenlab/projects/somaticNov2020/analysisfiles/resources-broad-hg38-v0-Homo_sapiens_assembly38.known_indels.vcf.gz
SAMPLE_MAP=$INPUT_DIR/sample_map.txt

for CHR in chr{1..22} chrX chrY; do

# ------------------ STEP 1: GenomicsDBImport ------------------
jobid1=$(sbatch -t 4- -n 20 -N 1 --output=$INPUT_DIR/combine_gvcf_${CHR}.out \
  --mem=60g -J combine --wrap="gatk --java-options '-Xmx60g -Xms60g' GenomicsDBImport \
  --genomicsdb-workspace-path $INPUT_DIR/genomicsworkspace_${CHR} \
  --batch-size 50 \
  --sample-name-map $SAMPLE_MAP \
  -R $REF \
  --consolidate true \
  --reader-threads 5 \
  -L $CHR \
  -OVI true")
echo $jobid1
jobid1=${jobid1##* }


# ------------------ STEP 2: GenotypeGVCFs ------------------
jobid2=$(sbatch --dependency=afterok:$jobid1 -t 4- -n 20 -N 1 \
  --output=$INPUT_DIR/genotype_gvcf_${CHR}.out \
  --mem=60g -J genotype --wrap="gatk --java-options '-Xmx40g -Xms40g -XX:ParallelGCThreads=4' GenotypeGVCFs \
  -R $REF \
  -V gendb://$INPUT_DIR/genomicsworkspace_${CHR} \
  -G StandardAnnotation \
  --dbsnp $KNOWN_SITES1 \
  -O $INPUT_DIR/genotyped_${CHR}.vcf \
  -OVI true")
echo $jobid2
jobid2=${jobid2##* }


# ------------------ STEP 3: SelectVariants (SNPs) & VariantFiltration (SNPs) ------------------
jobid3=$(sbatch --dependency=afterok:$jobid2 -t 4- -n 20 -N 1 \
  --output=$INPUT_DIR/select_var_${CHR}.out \
  --mem=60g -J select_filter_snps --wrap="gatk --java-options '-Xmx40g -Xms40g' SelectVariants \
  -V $INPUT_DIR/genotyped_${CHR}.vcf \
  --select-type-to-include SNP \
  -O $INPUT_DIR/joint_snps_${CHR}.vcf && \
  gatk --java-options '-Xmx40g -Xms40g' VariantFiltration \
  -V $INPUT_DIR/joint_snps_${CHR}.vcf \
  --filter-expression 'QD < 2.0 || FS > 60.0 || MQ < 40.0 || MQRankSum < -12.5 || ReadPosRankSum < -8.0' \
  --filter-name 'my_snp_filter' \
  -O $INPUT_DIR/filtered_snps_${CHR}.vcf \
  -OVI true")

echo $jobid3
jobid3=${jobid3##* }


# ------------------ STEP 4: SelectVariants (INDELs) & VariantFiltration (INDELs) ------------------
jobid4=$(sbatch --dependency=afterok:$jobid2 -t 4- -n 20 -N 1 \
  --output=$INPUT_DIR/filter_indel_${CHR}.out \
  --mem=60g -J filter_indel --wrap="gatk --java-options '-Xmx40g -Xms40g' \
  SelectVariants -V $INPUT_DIR/genotyped_${CHR}.vcf \
  --select-type-to-include INDEL \
  -O $INPUT_DIR/joint_indels_${CHR}.vcf && \
  gatk --java-options '-Xmx40g -Xms40g' VariantFiltration \
  -V $INPUT_DIR/joint_indels_${CHR}.vcf \
  --filter-expression 'QD < 2.0 || FS > 200.0 || ReadPosRankSum < -20.0' \
  --filter-name 'my_indel_filter' \
  -O $INPUT_DIR/filtered_indels_${CHR}.vcf \
  -OVI true")
echo $jobid4
jobid4=${jobid4##* }

done

# ------------------ STEP 5: Consolidate filtered SNPs and INDELs ------------------

FILTERED_SNP_LIST=$INPUT_DIR/joint_filtered_snps_list.txt
FILTERED_INDEL_LIST=$INPUT_DIR/joint_filtered_indels_list.txt
RAW_VCF_LIST=$INPUT_DIR/joint_raw_genotyped_list.txt

for CHR in chr{1..22} chrX chrY; do
  echo "$INPUT_DIR/filtered_snps_${CHR}.vcf" >> "$FILTERED_SNP_LIST"
  echo "$INPUT_DIR/filtered_indels_${CHR}.vcf" >> "$FILTERED_INDEL_LIST"
  echo "$INPUT_DIR/genotyped_${CHR}.vcf" >> "$RAW_VCF_LIST"
done

gatk --java-options "-Xmx40g" GatherVcfs \
  -I $RAW_VCF_LIST \
  -O "$INPUT_DIR/joint_genotyped_unfiltered_GATK_calls.vcf"

gatk --java-options "-Xmx40g" GatherVcfs \
  -I $FILTERED_SNP_LIST \
  -O "$INPUT_DIR/joint_filtered_snps.vcf"

gatk --java-options "-Xmx40g" GatherVcfs \
  -I $FILTERED_INDEL_LIST \
  -O "$INPUT_DIR/joint_filtered_indels.vcf"

gatk --java-options "-Xmx40g" MergeVcfs \
  -I "$INPUT_DIR/joint_filtered_snps.vcf" \
  -I "$INPUT_DIR/joint_filtered_indels.vcf" \
  -O "$INPUT_DIR/final_filtered_GATK_calls.vcf"

echo "All VCFs gathered and merged"

#NOTE: Adapted from: GATK legacy: germline calling 
#src: https://sites.google.com/a/broadinstitute.org/legacy-gatk-forum-discussions/tutorials/2806-how-to-apply-hard-filters-to-a-call-set 

