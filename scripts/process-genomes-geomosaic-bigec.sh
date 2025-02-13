#!/bin/bash

# Taken from https://unix.stackexchange.com/a/505342
helpFunction()
{
  echo ""
  echo "Usage: $0 -input_dir"
  echo -e "\t-i Input directory containing the files for each accesion"
  exit 1 # Exit script after printing help
}

while getopts "i:" opt
do
  case "$opt" in
    i ) input_dir="$OPTARG" ;;
    ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
  esac
done

# Print helpFunction in case parameters are empty
if [ -z "$input_dir" ]
then
  echo "Some or all of the parameters are empty";
  helpFunction
fi

# ---------------------------------------------------------------------------- #

out_dir=${input_dir}/mags_orfs/
mkdir -p $out_dir

for file in ${input_dir}/*/mags_prodigal/mag_*/orf_predicted.faa; do

  # Get MAG ID
  mag_id=$(basename $(dirname $file))

  # Move up three times to get sample name
  sample_name=$(dirname $(dirname $(dirname $file)))
  sample_name=$(basename $sample_name)

  # Copy ORFs to a new file in the input directory
  out_file=${out_dir}/${sample_name}_${mag_id}.faa
  cp $file $out_file
  echo "[+] Copied ${out_file}"

done

echo "[SUCCESS] ORFs saved to ${out_dir}"
