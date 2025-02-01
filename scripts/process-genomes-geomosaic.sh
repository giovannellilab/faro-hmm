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

project_name=$(basename $input_dir)

# Initialize output file
out_file=$(realpath ${input_dir}/${project_name}.faa)
cat /dev/null > $out_file

for file in ${input_dir}/*/mags_prodigal/mag_*/orf_predicted.faa; do

  # Move up three times to get sample name
  sample_name=$(dirname $(dirname $(dirname $file)))
  sample_name=$(basename $sample_name)

  # Add header to predicted ORFs
  header=${project_name}_${sample_name}
  cat $file | sed "s|\>|\>${header}_|g" >> $out_file

done

echo "Merged ORFs saved to: ${out_file}"
