#This step is used to create a panel of normals which will be utilized for running CNVradar. 
# NOTE: Samples utilized to create a panel of normals need to be preppped and sequenced using same method as the query samples 

 # ---------- STEP 1: Generate region of interest files  ----------
#!/bin/bash
#SBATCH -t 07-00:00:00
#SBATCH --mem=20g

module load r/3.6.0
module load bedtools
module load snpeff

for filename in $(cat /proj/heinzenlab/projects/somaticNov2020/germline/CNV_MG/WGS/bam.list.txt)

do 
sbatch --time=100:00:00 --mem=8g --job-name gen-roi --wrap="sh /proj/heinzenlab/projects/somaticNov2020/germline/CNV_MG/WGS/gen.roi.sh $filename"

sleep 1
done
## Here bam.list.txt looks like:
/overflow/heinzenlab/UNCbams.fastq/exome/erka123leuko/bams/erka123leuko.bwamem.sorted.marked.bam
/overflow/heinzenlab/UNCbams.fastq/exome/erka17pbmc/bams/erka17pbmc.bwamem.sorted.marked.bam
/overflow/heinzenlab/UNCbams.fastq/exome/erka313leuko/bams/erka313leuko.bwamem.sorted.marked.bam
/overflow/heinzenlab/UNCbams.fastq/exome/erka314leuko/bams/erka314leuko.bwamem.sorted.marked.bam
/overflow/heinzenlab/UNCbams.fastq/exome/uth0020bl/bams/uth0020bl.bwamem.sorted.marked.bam

## Here gen.roi.sh looks like:

#!/bin/bash
filename=$1

Rscript /proj/heinzenlab/projects/somaticNov2020/germline/CNV_MG/CNVRadar/CNV_Radar-master/bam2roi.r -b "$filename"  -d /proj/heinzenlab/projects/somaticNov2020/analysisfiles/CCDShg18exons+2bp.GRCh38.p12.CCDSv22.bed -z >> bam2roi.log 2>&1


 # ---------- STEP 2: Create PON  ----------
#!/bin/bash
#SBATCH -t 07-00:00:00
#SBATCH --mem=20g


module load r/3.6.0
module load bedtools
module load snpeff

for f in *_roiSummary.txt
do
	Rscript /proj/heinzenlab/projects/somaticNov2020/germline/CNV_MG/CNVRadar/CNV_Radar-master/CNV_Radar_create_control.r --directory /proj/heinzenlab/projects/somaticNov2020/germline/CNV_MG/WGS/controls/ >> create_normal_cohort.log 2>&1
done

