#!/bin/bash

cpu_nrs=12

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
  --cpu $cpu_nrs \
  --tblout "${out_dir}/${filename}_hmmer.txt" \
  $hmm_file $input_file > "${out_dir}/${filename}_hmmer.out"
