# pipeline-hmm

Pipeline for generating HMM profiles and functionally annotating with them.

## Installation

```bash
conda create -n pipeline-hmm -y
conda activate pipeline-hmm

# Install general dependencies
conda install mafft clipkit hmmer -y
conda install scikit-learn pandas xlrd openpyxl plotly seaborn fastcluster -y

# Install NCBI utilities
conda install -c conda-forge ncbi-datasets-cli -y
pip install ncbi-genome-download ete3 six
```
