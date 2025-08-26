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

# Create output directory for each sample
out_dir=$sample_dir/mags_orf_abundance/
mkdir -p $out_dir

# ---------------------------------------------------------------------------- #
# Get depth of coverage for each ORF in each MAG

# Define header and replace separator by tab
header="id,start,end,unnamed,score,strand,source,feature,frame,attr,depth,readcount,readcountsample"
header=$(echo "${header}" | tr , \\t)

for file in $sample_dir/mags_prodigal/mag_*/genes.gff; do

  # Create MAG folder in output directory
  mag_id=$(basename $(dirname $file))
  mag_dir=$out_dir/$mag_id
  mkdir -p $mag_dir

  # Generate BED file for samtools bedcov
  gff2bed --do-not-sort < $file > $mag_dir/genes.bed

  # Remove "mag_*_" from the BED file, since the BAM file contains contig IDs
  sed -i"" -e "s/${mag_id}_//g" $mag_dir/genes.bed

  # Get depth of coverage (defaul) and read counts (-c flag) per ORF
  samtools bedcov \
    -c \
    $mag_dir/genes.bed \
    $sample_dir/bowtie2/read_mapping_sorted.bam \
    > $mag_dir/${mag_id}_orf_depth.tsv

  # Add total number of reads sequenced per sample from FastQC output
  total_reads=$(cat $sample_dir/fastqc_readscount/geomosaic_readscount.txt)
  sed -i"" -e "s/$/\t${total_reads}/" $mag_dir/${mag_id}_orf_depth.tsv

  # Add GFF columns (https://www.ensembl.org/info/website/upload/gff.html)
  sed -i"" -e "1s/^/${header}\n/" $mag_dir/${mag_id}_orf_depth.tsv

  echo "[+] Depth of coverage and read counts calculated for: ${mag_id}"

done

# ---------------------------------------------------------------------------- #
# Combine all MAGs and normalize counts per sample

python3 process_orf_abundance.py -i $sample_dir

echo "[FINISHED] Depth of coverage and read counts calculated for all MAGs"
