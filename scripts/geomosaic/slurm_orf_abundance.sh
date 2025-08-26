#!/bin/bash

# ---------------------------------------------------------------------------- #
# WARNING:
# 1) Define Geomosaic directory in the script, also for SLURM logs
# 2) Change the number of array to the number of samples

geomosaic_dir=""

# ---------------------------------------------------------------------------- #

#SBATCH --job-name="ABD"
#SBATCH --time=96:00:00
#SBATCH --cpus-per-task=10
#SBATCH --mem=50G
#SBATCH --array=1-TODO_CHANGE
#SBATCH --output=$geomosaic_dir/slurm_logs/slurm-%A_%a.out
#SBATCH --partition=parallel

# ---------------------------------------------------------------------------- #
# REQUIREMENTS:
#   * Total number of reads per sample (geomosaic_readscount.txt): FastQC
#   * Read mapping output (read_mapping_sorted.bam): either bowtie2 or BBmap
#   * ORF prediction output (genes.gff): Prodigal
# ---------------------------------------------------------------------------- #

single_sample="$(tail -n +$SLURM_ARRAY_TASK_ID $geomosaic_dir/list_samples.txt | head -n1)"

echo "SAMPLE: $single_sample"

# Define paths
sample_dir=$geomosaic_dir/geomosaic/$single_sample
orf_dir=$sample_dir/prodigal/
readmap_dir=$sample_dir/bowtie2

# Create output directory for each sample
out_dir=$sample_dir/orf_abundance/
mkdir -p $out_dir

# ---------------------------------------------------------------------------- #
# Get depth of coverage for each ORF in each assembly

# Define header (see https://www.ensembl.org/info/website/upload/gff.html)
header="id,start,end,unnamed,score,strand,source,feature,frame,attr,depth,readcount,readcountsample"

# Replace separator by tabs (default separator in GFF files)
header=$(echo "${header}" | tr , \\t)

# Generate BED file for samtools bedcov
gff2bed --do-not-sort < $orf_dir/genes.gff > $out_dir/genes.bed

# Get depth of coverage (defaul) and read counts (-c flag) per ORF
samtools bedcov \
  -c \
  $out_dir/genes.bed \
  $readmap_dir/read_mapping_sorted.bam \
  > $out_dir/orf_depth.tsv

# Add columnn for total number of reads sequenced per sample from FastQC
total_reads=$(cat $sample_dir/fastqc_readscount/geomosaic_readscount.txt)
sed -i"" -e "s/$/\t${total_reads}/" $out_dir/orf_depth.tsv

# Add header
sed -i"" -e "1s/^/${header}\n/" $out_dir/orf_depth.tsv

# ---------------------------------------------------------------------------- #
# Combine all MAGs and normalize counts per sample

python3 process_orf_abundance.py --input_dir $sample_dir --level assembly

echo "[FINISHED] Depth of coverage and read counts calculated for the assembly"
