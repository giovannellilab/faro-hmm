#!/bin/bash

INPUT_DIR="../data/genomes/HighQ_Aquificota_Sequences_AA/"

# WARNING: change extension to avoid infinite loop (any .fa is listed by find)
# Otherwise, change final output directory
OUT_FILE=$(dirname $INPUT_DIR)/$(basename $INPUT_DIR).fa

# Add filename after ">"
find $INPUT_DIR -name "*.fa" -type f -execdir sed "s|\>|\>{}_|g" {} \; > $OUT_FILE

# Remove extension
sed -i "" "s|\.fa||g" $OUT_FILE
