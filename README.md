# FARO-HMM

![logo](https://github.com/guillecg/designs/blob/main/logos/faro.jpg)

Logo licensed under CC-BY-NC-SA (4.0).

<br>

**FARO-HMM (Functional Annotation of Reactions using Orthologs and Hidden Markov Models)** is a tool for studying biogeochemical cycles in environmental assemblies and MAGs (metagenome-assembled genomes).


## Installation

```bash
conda create -n faro-hmm python -y
conda activate faro-hmm

# Install NCBI utilities
conda install -c conda-forge ncbi-datasets-cli sra-tools -y
pip install ncbi-genome-download ete3 six

# Install general dependencies
conda install mafft clipkit iqtree hmmer -y
conda install scikit-learn pandas xlrd openpyxl plotly seaborn fastcluster -y
```
