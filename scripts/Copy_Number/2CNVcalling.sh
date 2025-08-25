 #---------- STEP 1: Generate ROI files ----------
 #gvcfs need to be generated using gatk haplotype caller to be able to annotate these files and utilize them for CNV calling 

 #!/bin/bash
#SBATCH -N 1
#SBATCH -n 6
#SBATCH -p general
#SBATCH --nice=30 
#SBATCH -t 07-00:00:00
#SBATCH --mem=140g

module load r/3.6.0
module load bedtools
module load snpeff/4.3

for filename in `cat /proj/heinzenlab/projects/somaticNov2020/germline/CNV_MG/WGS/vcf.list` 
do 
sbatch --time=100:00:00 --mem=8g --job-name unzip --wrap="sh /proj/heinzenlab/projects/somaticNov2020/germline/CNV_MG/Agilent/annotate.sh $filename"
sleep 1
done

 #---------- STEP 2: Generate annotation files ----------

 #SBATCH -N 1
#SBATCH -n 6
#SBATCH -p general
#SBATCH --nice=30 
#SBATCH -t 07-00:00:00
#SBATCH --mem=140g

module load r/3.6.0
module load bedtools
module load snpeff/
module load snpeff/4.3

java -jar /nas/longleaf/apps/snpeff/4.3/snpEff/SnpSift.jar annotate /proj/heinzenlab/projects/somaticNov2020/germline/CNV_MG/dbSnp/All_20180418.vcf.gz "$filename" | bgzip > $(basename "$filename" .g.vcf.gz).annotated


 #---------- STEP 3: Run CNV radar -----------------------------
 
#SBATCH -N 1
#SBATCH -n 6
#SBATCH -p general
#SBATCH --nice=30 
#SBATCH -t 07-00:00:00
#SBATCH --mem=320g
module load r/4.0.1
module load bedtools
module load snpeff/4.3

Rscript /proj/heinzenlab/projects/somaticNov2020/germline/CNV_MG/CNVRadar/CNV_Radar.r \
 -c /proj/heinzenlab/projects/somaticNov2020/germline/CNV_MG/WGS/controls/cnvradar_normal_cohort.RData \
 -r /proj/heinzenlab/projects/somaticNov2020/germline/CNV_MG/WGS/JME304_ATTCCATA-TGCCTGGT_S1_sorted_roiSummary.txt \
 -v /proj/heinzenlab/projects/somaticNov2020/germline/CNV_MG/WGS/JME304.g.vcf.gz.annotated  -G

 
