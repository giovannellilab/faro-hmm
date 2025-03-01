#!/bin/bash

#SBATCH --job-name="hmmer"
#SBATCH --time=160:00:00
#SBATCH --cpus-per-task=80
#SBATCH --mem=80G
#SBATCH --partition=parallel

# Taken from https://unix.stackexchange.com/a/505342
helpFunction()
{
  echo ""
  echo "Usage: $0 -i input_file -p hmm_file"
  echo -e "\t-i Genomes file"
  echo -e "\t-p HMM file"
  exit 1 # Exit script after printing help
}

while getopts "i:p:" opt
do
  case "$opt" in
    i ) input_file="$OPTARG" ;;
    p ) hmm_file="$OPTARG" ;;
    ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
  esac
done

# Print helpFunction in case parameters are empty
if [ -z "$input_file" ] || [ -z "$hmm_file" ]
then
  echo "Some or all of the parameters are empty";
  helpFunction
fi

# ---------------------------------------------------------------------------- #

out_dir=$(dirname $input_file)
filename=$(basename $input_file | cut -d. -f1)

hmmsearch \
  --cpu $SLURM_CPUS_PER_TASK \
  --tblout "${out_dir}/${filename}_hmmer.txt" \
  -E 1e-5 \
  --domE 1e-5 \
  $hmm_file $input_file > /dev/null 2>&1
