#!/bin/bash

# Taken from https://unix.stackexchange.com/a/505342
helpFunction()
{
  echo ""
  echo "Usage: $0 -input_dir"
  echo -e "\t-i Input directory containing the files for each accesion"
  echo -e "\t-e Extension of the data files"
  exit 1 # Exit script after printing help
}

while getopts "i:e:" opt
do
  case "$opt" in
    i ) input_dir="$OPTARG" ;;
    e ) file_ext="$OPTARG" ;;
    ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
  esac
done

# Print helpFunction in case parameters are empty
if [ -z "$input_dir" ]|| [ -z "$file_ext" ]
then
  echo "Some or all of the parameters are empty";
  helpFunction
fi

# ---------------------------------------------------------------------------- #

# WARNING: change extension to avoid infinite loop (any .fa is listed by find)
# Otherwise, change final output directory
out_file=$(dirname $input_dir)/$(basename $input_dir).${file_ext}

# Add filename after ">"
find $input_dir \
  -name "*.${file_ext}" \
  -type f -execdir sed "s/>/>{}_/g" {} \; > $out_file

# Remove extension
sed -i "" "s/\.fa//g" $out_file
