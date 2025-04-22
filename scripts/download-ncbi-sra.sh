#!/bin/bash

#SBATCH --job-name="SRR"
#SBATCH --time=160:00:00
#SBATCH --cpus-per-task=40
#SBATCH --mem=40G
#SBATCH --partition=parallel

# Taken from https://unix.stackexchange.com/a/505342
helpFunction()
{
  echo ""
  echo "Usage: $0 -i srr_id"
  echo -e "\t-i SRR identifier"
  exit 1 # Exit script after printing help
}

while getopts "i:" opt
do
  case "$opt" in
    i ) srr_id="$OPTARG" ;;
    ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
  esac
done

# Print helpFunction in case parameters are empty
if [ -z "$srr_id" ]
then
  echo "Some or all of the parameters are empty";
  helpFunction
fi

# ---------------------------------------------------------------------------- #

echo "[+] Processing ${srr_id}"

# WARNING: be careful with disk limit! Try to use the --disk-limit option
fasterq-dump $srr_id \
  --force \
  --split-3 \
  --skip-technical \
  --mem $SLURM_MEM_PER_NODE \
  --threads $SLURM_CPUS_PER_TASK \
  --progress \
  --details \
  --verbose
