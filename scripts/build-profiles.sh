#!/bin/bash

# Taken from https://unix.stackexchange.com/a/505342
helpFunction()
{
  echo ""
  echo "Usage: $0 -d input_dir -o out_dir -p out_prefix"
  echo -e "\t-i Input directory containing the sequences (one .fasta per HMM)"
  echo -e "\t-o Output directory for the HMM profile"
  echo -e "\t-p Prefix for naming the concatenated HMM file (no extension)"
  exit 1 # Exit script after printing help
}

while getopts "i:o:p:" opt
do
  case "$opt" in
    i ) input_dir="$OPTARG" ;;
    o ) out_dir="$OPTARG" ;;
    p ) out_prefix="$OPTARG" ;;
    ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
  esac
done

# Print helpFunction in case parameters are empty
if [ -z "$input_dir" ] || [ -z "$out_dir" ] || [ -z "$out_prefix" ]
then
  echo "Some or all of the parameters are empty";
  helpFunction
fi

# ---------------------------------------------------------------------------- #

# Avoid memory leak by moving all .hmm files to another directory
# Otherwise, it will concatenate ${out_prefix}.hmm in a loop
indiv_dir=$out_dir/${out_prefix}_individual
mkdir -p $indiv_dir

files_list=$(find $input_dir/* -name "*.fasta" -type f -maxdepth 0)

for input_file in $files_list; do

  # Get filename without extension
  input_basename="${input_file%.*}"

  # Define paths
  aln_file=${input_basename}_aln
  clp_file=${input_basename}_aln_clp.sto
  hmm_indiv_file=$indiv_dir/$(basename $input_basename).hmm

  # Align sequences
  mafft --auto --anysymbol --thread -1 $input_file > $aln_file

  # Trim alignment
  clipkit $aln_file \
    --mode kpic-smart-gap \
    --output $clp_file \
    --output_file_format stockholm

  # Build the HMM profile and concatenate
  hmmbuild \
    -n $(basename $input_basename) \
    -O ${clp_file}.hmmer \
    $hmm_indiv_file \
    $clp_file

done

# Concatenate all generated HMM profiles
hmm_final_file=$out_dir/${out_prefix}.hmm
find $indiv_dir -name "*.hmm" -type f -exec cat > $hmm_final_file {} \;
