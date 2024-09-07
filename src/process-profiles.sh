#!/bin/bash

INPUT_DIR="../data/profiles/"
OUT_FILE=$INPUT_DIR/pipeline.hmm

SUFFIX=".source.hmm"

# ---------------------------------------------------------------------------- #
# Processing of HMMs from each source

# NOTE: before concatenating, hmmconvert must be run to update the profiles to
# the version used. For details, see https://www.biostars.org/p/114774/#215668

# Baker
find $INPUT_DIR/baker/Metabolic_genes_hmms/ -name "*.hmm" -type f \
    -exec hmmconvert {} \; > baker${SUFFIX}
find $INPUT_DIR/baker/Metabolic_genes_hmms/ -name "*.HMM" -type f \
    -exec hmmconvert {} \; >> baker${SUFFIX}

# MagicLamp
for folder in $(ls $INPUT_DIR/magiclamp/); do
    find $INPUT_DIR/magiclamp/$folder/ -name "*.hmm" -type f \
        -exec hmmconvert {} \; > magiclamp_${folder}${SUFFIX}
done

# METABOLIC
find $INPUT_DIR/metabolic/ -name "*.hmm" -type f \
    -exec hmmconvert {} \; > metabolic${SUFFIX}

# Metascan
find $INPUT_DIR/metascan/ -name "*.hmm" -type f \
    -exec hmmconvert {} \; > metascan${SUFFIX}

# ---------------------------------------------------------------------------- #
# Concatenation and post-processing

# Add source as prefix and concatenate to final file
find *${SUFFIX} -type f -exec sed "s/NAME  /NAME  {}_/g" {} \; > $OUT_FILE

# Remove source suffix
SUFFIX_ESC=$(echo $SUFFIX | sed "s/\./\\\./g")
sed -i "" "s/$(echo $SUFFIX_ESC)_/_/g" $OUT_FILE

# Cleanup
rm *${SUFFIX}
