# pipeline-hmm

Pipeline for generating HMM profiles and functionally annotating with them.

## Installation

```bash
# NOTE: for Mac M1/M2 chips, use "CONDA_SUBDIR=osx-64 conda create"
conda create -n pipeline-hmm -y
conda activate pipeline-hmm

# Install ncbi-genome-download and dependencies
conda install -c etetoolkit ete3 ete_toolchain ncbi-genome-download -y

# Sequence-related dependencies (mafft and iqtree installed with ete3)
conda install clipkit hmmer -y

# Data processing and visualization dependencies
conda install pandas xlrd plotly seaborn fastcluster -y
```
