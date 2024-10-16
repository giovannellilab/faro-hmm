#!/bin/bash

# Taken from https://unix.stackexchange.com/a/505342
helpFunction()
{
  echo ""
  echo "Usage: $0 -i input_file -p hmm_file -t num_threads"
  echo -e "\t-i Genomes file"
  echo -e "\t-p HMM file"
  echo -e "\t-t Number of threads to use"
  exit 1 # Exit script after printing help
}

while getopts "i:p:t:" opt
do
  case "$opt" in
    i ) input_file="$OPTARG" ;;
    p ) hmm_file="$OPTARG" ;;
    t ) num_threads="$OPTARG" ;;
    ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
  esac
done

# Print helpFunction in case parameters are empty
if [ -z "$input_file" ] || [ -z "$hmm_file" ] || [ -z "$num_threads" ]
then
  echo "Some or all of the parameters are empty";
  helpFunction
fi

# ---------------------------------------------------------------------------- #

out_dir=$(dirname $input_file)
filename=$(basename $input_file | cut -d. -f1)

hmmsearch \
  --cpu $num_threads \
  --tblout "${out_dir}/${filename}_hmmer.txt" \
  $hmm_file $input_file > "${out_dir}/${filename}_hmmer.out"
