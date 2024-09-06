#!/bin/bash

INPUT_DIR="../data/profiles/"
OUT_FILE=$INPUT_DIR/pipeline.hmm

SUFFIX=".source.hmm"


# ---------------------------------------------------------------------------- #
# Addition of HMMs from each source

# Baker
cat $INPUT_DIR/baker/Metabolic_genes_hmms/*.hmm > baker${SUFFIX}
cat $INPUT_DIR/baker/Metabolic_genes_hmms/*.HMM >> baker${SUFFIX}

# MagicLamp
for folder in $(ls $INPUT_DIR/magiclamp/); do
    cat $INPUT_DIR/magiclamp/$folder/*.hmm > magiclamp_${folder}${SUFFIX}
done

# METABOLIC
cat $INPUT_DIR/metabolic/*.hmm > metabolic${SUFFIX}

# Metascan
cat $INPUT_DIR/metascan/*.hmm > metascan${SUFFIX}


# ---------------------------------------------------------------------------- #
# Concatenation and post-processing

# Add source as prefix and concatenate to final file
find *${SUFFIX} -type f -exec sed "s/NAME  /NAME  {}_/g" {} \; > $OUT_FILE

# Remove source suffix
SUFFIX_ESC=$(echo $SUFFIX | sed "s/\./\\\./g")
sed -i "" "s/$(echo $SUFFIX_ESC)_/_/g" $OUT_FILE

# Cleanup
rm *${SUFFIX}
