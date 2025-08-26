#!/bin/bash

# ---------------------------------------------------------------------------- #
# WARNING:
# 1) Define Geomosaic directory in the script, also for SLURM logs
# 2) Change the number of array to the number of samples
# ---------------------------------------------------------------------------- #

#SBATCH --job-name="funp"
#SBATCH --time=96:00:00
#SBATCH --cpus-per-task=80
#SBATCH --mem=300G
#SBATCH --array=1-TODO_CHANGE
#SBATCH --output=$geomosaic_dir/slurm_logs/slurm-%A_%a.out
#SBATCH --partition=parallel

# Taken from https://unix.stackexchange.com/a/505342
helpFunction()
{
  echo ""
  echo "Usage: $0 -i expedition_dir -f fun_dir"
  echo -e "\t-i Expedition directory"
  echo -e "\t-f Funprofiler directory"
  exit 1 # Exit script after printing help
}

while getopts "i:f:" opt
do
  case "$opt" in
    i ) expedition_dir="$OPTARG" ;;
    f ) fun_dir="$OPTARG" ;;
    ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
  esac
done

# Print helpFunction in case parameters are empty
if [ -z "$expedition_dir" ] || [ -z "$fun_dir" ]
then
  echo "Some or all of the parameters are empty";
  helpFunction
fi

# ---------------------------------------------------------------------------- #

sample_id="$(tail -n +$SLURM_ARRAY_TASK_ID ${expedition_dir}/list_samples.txt | head -n1)"

echo
echo "-------------------------------------------------------------------------"
echo "Funprofiler path: ${fun_dir}"
echo "Expedition ID:    ${expedition_dir}"
echo "Sample ID:        ${sample_id}"
echo

sample_dir=${expedition_dir}/geomosaic/${sample_id}
sample_dir_funprof=${sample_dir}/funprof/

# Create output directory
mkdir -p $sample_dir_funprof
cd $sample_dir_funprof

# Concatenate paired-end reads
echo "[+] Concatenating reads for sample ${sample_id}..."
seq_file=${sample_id}_concat.gz
cat ${sample_dir}/fastp/R*.fastq.gz > $seq_file
echo "[+] Reads successfully concatenated into ${seq_file}"

echo
echo "-------------------------------------------------------------------------"
echo

# Run funprofiler
python ${fun_dir}/funcprofiler.py \
  $seq_file \
  ${fun_dir}/KOs_sketched_scaled_1000.sig.zip \
  11 \
  1000 \
  ko_profiles.csv \
  -t 1000 \
  -p prefetch_out.txt

# Remove concatenated file to save space on disk
echo "[+] Removing concatenated reads for sample ${sample_id}..."
rm $seq_file

echo "[SUCCESS] funprofiler job finished for sample ${sample_id}"
