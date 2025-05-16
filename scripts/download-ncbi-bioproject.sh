#!/bin/bash

# Taken from https://unix.stackexchange.com/a/505342
helpFunction()
{
  echo ""
  echo "Usage: $0 -i bioproject_id -d data_dir"
  echo -e "\t-i NCBI BioProject ID"
  echo -e "\t-d Directory that will contain the data files"
  exit 1 # Exit script after printing help
}

while getopts "i:d:" opt
do
  case "$opt" in
    i ) bioproject_id="$OPTARG" ;;
    d ) data_dir="$OPTARG" ;;
    ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
  esac
done

# Print helpFunction in case parameters are empty
if [ -z "$bioproject_id" ] || [ -z "$data_dir" ]
then
  echo "Some or all of the parameters are empty";
  helpFunction
fi

# ---------------------------------------------------------------------------- #

cd $data_dir

# Download entire NCBI BioProject
datasets download genome accession ${bioproject_id} \
  --filename ${bioproject_id}.zip \
  --include protein

# Extract downloaded files
unzip ${bioproject_id}.zip && mv ncbi_dataset $bioproject_id

# Reorganize downloaded files
for file in ${bioproject_id}/data/*/protein.faa
  do
    accession=$(basename $(dirname $file))
    mv ${file} ${bioproject_id}/${accession}.faa
  done

# Clean files
rm ${bioproject_id}.zip
rm -r ${bioproject_id}/data
rm README.md
rm md5sum.txt
