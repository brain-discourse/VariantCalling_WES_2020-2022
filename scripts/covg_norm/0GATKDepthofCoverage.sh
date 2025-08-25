# These script generate coverage data using GATK depth of coverage


#------------------------------------------ Chromosome wide------------------------------------------
#!/bin/bash
 
module add samtools 
module add biobambam2
module add bbmap
module add bwa/0.7.15
module add java
module add picard/2.21.7
module add gatk/4.1.9.0 
 
OUTPUT_DIR=/proj/heinzenlab/projects/somaticNov2020/coverage
RAW_DIR=/overflow/heinzenlab/UNCbams.fastq/exome
 
SAMPLE_NAME=$1
 
REF=/proj/heinzenlab/projects/somaticNov2020/analysisfiles/GRCh38.d1.vd1.fa
CHR=/proj/heinzenlab/projects/somaticNov2020/analysisfiles/chrband.bed
 
mkdir $OUTPUT_DIR/$SAMPLE_NAME/
 
#coverage
jobid1=$(sbatch -t 2-00:00:00 -n 20 -N 1 --output=/$OUTPUT_DIR/$SAMPLE_NAME/${SAMPLE_NAME}.CHRcoverage.out --mem=20g -p general -J CHRcoverage --wrap="gatk DepthOfCoverage \
               -I /$RAW_DIR/$SAMPLE_NAME/bams/${SAMPLE_NAME}.bwamem.sorted.marked.bam \
               -R $REF \
               -L $CHR \
             -O /$OUTPUT_DIR/$SAMPLE_NAME/${SAMPLE_NAME}.CHRcoverage ")
echo $jobid1

#------------------------------------------ CCDS wide------------------------------------------

module add samtools 
module add biobambam2
module add bbmap
module add bwa/0.7.15
module add java
module add picard/2.21.7
module add gatk/4.1.9.0 

OUTPUT_DIR=/proj/heinzenlab/projects/somaticNov2020/coverage
RAW_DIR=/overflow/heinzenlab/UNCbams.fastq/exome

SAMPLE_NAME=$1

REF=/proj/heinzenlab/projects/somaticNov2020/analysisfiles/GRCh38.d1.vd1.fa
CCDS=/proj/heinzenlab/projects/somaticNov2020/analysisfiles/CCDShg18exons+2bp.GRCh38.p12.CCDSv22.bed
GENELIST=/proj/heinzenlab/projects/somaticNov2020/analysisfiles/refseqgenes.refseq

mkdir /$OUTPUT_DIR/$SAMPLE_NAME/
mkdir $OUTPUT_DIR/$SAMPLE_NAME/
#coverage
jobid1=$(sbatch -t 2-00:00:00 -n 20 -N 1 --output=/$OUTPUT_DIR/$SAMPLE_NAME/${SAMPLE_NAME}.coverage.out --mem=20g -p general -J coverage --wrap="gatk DepthOfCoverage \
               -I /$RAW_DIR/$SAMPLE_NAME/bams/${SAMPLE_NAME}.bwamem.sorted.marked.merged.bam \
               -R $REF \
               -L $CCDS \
         -O /$OUTPUT_DIR/$SAMPLE_NAME/${SAMPLE_NAME}.coverage \
         -gene-list $GENELIST \
               --summary-coverage-threshold 50 ")
echo $jobid1
# Extract the job ID from the output of the sbatch command for further use
jobid1=${jobid1##* }
