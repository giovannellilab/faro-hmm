# pipeline-hmm

Pipeline for generating HMM profiles and functionally annotating with them.

## Installation

```bash
conda create -n pipeline-hmm -y
conda activate pipeline-hmm

# Install general dependencies
conda install mafft clipkit hmmer -y
conda install scikit-learn pandas xlrd openpyxl plotly seaborn fastcluster -y

# Install ncbi-genome-download and dependencies
pip install ncbi-genome-download ete3 six
```
