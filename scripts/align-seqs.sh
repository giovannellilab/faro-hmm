#!/bin/bash

# Taken from https://unix.stackexchange.com/a/505342
helpFunction()
{
  echo ""
  echo "Usage: $0 -input_file"
  echo -e "\t-i Input file containing the sequences to align"
  exit 1 # Exit script after printing help
}

while getopts "i:" opt
do
  case "$opt" in
    i ) input_file="$OPTARG" ;;
    ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
  esac
done

# Print helpFunction in case parameters are empty
if [ -z "$input_file" ]
then
  echo "Some or all of the parameters are empty";
  helpFunction
fi

# ---------------------------------------------------------------------------- #

# Get filename without extension
output_file="${input_file%.*}"
output_file=${output_file}_aln.fasta

mafft --auto --anysymbol --thread -1 $input_file > $output_file

clipkit $output_file
