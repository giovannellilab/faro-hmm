#!/bin/bash

#SBATCH --job-name="hmmer"
#SBATCH --time=160:00:00
#SBATCH --cpus-per-task=80
#SBATCH --mem=400G
#SBATCH --partition=parallel

filename=$(basename $2)

hmmsearch --cpu $SLURM_CPUS_PER_TASK --tblout "${filename}_hmmer.txt" $1 $2
