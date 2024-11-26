# pipeline-hmm

Pipeline for generating HMM profiles and functionally annotating with them.

## Installation

```bash
conda create -n pipeline-hmm -y
conda activate pipeline-hmm

# Sequence-related dependencies
conda install conda-forge::mafft clipkit iqtree hmmer ncbi-genome-download -y

# Data processing and visualization dependencies
conda install pandas plotly seaborn fastcluster -y
```
