#!/bin/bash

# Taken from https://unix.stackexchange.com/a/505342
helpFunction()
{
  echo ""
  echo "Usage: $0 -input_dir"
  echo -e "\t-i Input directory containing the HMM folders for each source"
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

cd $input_dir

out_file=pipeline.hmm
suffix=".source.hmm"

# ---------------------------------------------------------------------------- #
# Processing of HMMs from each source

# NOTE: before concatenating, hmmconvert must be run to update the profiles to
# the version used. For details, see https://www.biostars.org/p/114774/#215668

# Baker
find baker/Metabolic_genes_hmms/ -name "*.hmm" -type f \
    -exec hmmconvert {} \; > baker${suffix}
find baker/Metabolic_genes_hmms/ -name "*.HMM" -type f \
    -exec hmmconvert {} \; >> baker${suffix}

# MagicLamp
for folder in $(ls magiclamp/); do
    find magiclamp/$folder/ -name "*.hmm" -type f \
        -exec hmmconvert {} \; > magiclamp_${folder}${suffix}
done

# METABOLIC
find metabolic/ -name "*.hmm" -type f \
    -exec hmmconvert {} \; > metabolic${suffix}

# Metascan
find metascan/ -name "*.hmm" -type f \
    -exec hmmconvert {} \; > metascan${suffix}

# Barosa
find barosa/ -name "*.hmm" -type f \
    -exec hmmconvert {} \; > barosa${suffix}

# ---------------------------------------------------------------------------- #
# Concatenation and post-processing

# Add source as prefix and concatenate to final file
find *${suffix} -type f -exec sed "s/NAME  /NAME  {}_/g" {} \; > $out_file

# Remove source suffix
suffix_esc=$(echo $suffix | sed "s/\./\\\./g")
sed -i "" "s/$(echo $suffix_esc)_/_/g" $out_file

# Cleanup
rm *${suffix}
