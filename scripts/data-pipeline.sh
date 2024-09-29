#!/bin/bash

# Taken from https://unix.stackexchange.com/a/505342
helpFunction()
{
  echo ""
  echo "Usage: $0 -n tax_name -o out_dir -t num_threads"
  echo -e "\t-n Parent NCBI taxonomy name"
  echo -e "\t-o Output directory"
  echo -e "\t-t Number of threads to use"
  exit 1 # Exit script after printing help
}

while getopts "n:o:t:" opt
do
  case "$opt" in
    n ) tax_name="$OPTARG" ;;
    o ) out_dir="$OPTARG" ;;
    t ) num_threads="$OPTARG" ;;
    ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
  esac
done

# Print helpFunction in case parameters are empty
if [ -z "$tax_name" ] || [ -z "$out_dir" ] || [ -z "$num_threads" ]
then
  echo "Some or all of the parameters are empty";
  helpFunction
fi

# ---------------------------------------------------------------------------- #

# Convert taxonomy name to lower case
tax_name_lower=$(echo $tax_name | tr "[:upper:]" "[:lower:]")

# Create folder for the given taxonomy
out_dir=$out_dir/$tax_name_lower
mkdir -p $out_dir

# Get list of taxon IDs from NCBI
taxids_file=$out_dir/${tax_name_lower}_taxids.txt
gimme_taxa.py -j -o $taxids_file $tax_name

# Download the assemblies
ncbi-genome-download \
  --taxids $taxids_file \
  --format "fasta" \
  --parallel $num_threads \
  --output-folder $out_dir \
  --flat-output \
  --progress-bar \
  bacteria
