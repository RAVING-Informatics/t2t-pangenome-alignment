# T2T Re-alignment

# Release Paper

[The complete sequence of a human genome](https://www.science.org/doi/10.1126/science.abj6987)

# T2T Resources

**GitHub Repository** 

[GitHub - marbl/CHM13: The complete sequence of a human genome](https://github.com/marbl/CHM13)

**T2T Assembly Fasta File**

- `chm13v2.0.fa.gz: CHM13 v2.0 assembly`
- The CHM13v2.0 reference genome is available for download [here](https://www.notion.so/T2T-Re-alignment-d358656c0d494dd9922ed24d84d36821?pvs=21)

**Genome Annotation**

- GFF/GFF files

[Index of /genomes/all/GCF/009/914/755/GCF_009914755.1_T2T-CHM13v2.0](https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/009/914/755/GCF_009914755.1_T2T-CHM13v2.0/)

**T2T-Aligned VCFs**

- 1000Genomes (SNPs/Indels)

[human-pangenomics](https://s3-us-west-2.amazonaws.com/human-pangenomics/index.html?prefix=T2T/CHM13/assemblies/variants/1000_Genomes_Project/chm13v2.0/all_samples_3202/)

- gnomAD v3.1.2 liftover

[Index of /pub/rapid-release/species/Homo_sapiens/GCA_009914755.4/ensembl/variation/2022_10/vcf](https://ftp.ensembl.org/pub/rapid-release/species/Homo_sapiens/GCA_009914755.4/ensembl/variation/2022_10/vcf/)

# **Pipeline / Workflow**

`sarek - nfcore`

[sarek: Introduction](https://nf-co.re/sarek/3.4.0)

![Untitled 1](https://github.com/RAVING-Informatics/T2T-alignment/assets/58469884/afbd5e4c-b5c5-4712-b0ec-fbe048209579)

![Untitled](https://github.com/RAVING-Informatics/T2T-alignment/assets/58469884/3fd3bb36-4a01-4d7b-a265-cadd290a569d)

### Workflow Config for Setonix

[nf-core/configs: pawsey_setonix](https://nf-co.re/configs/pawsey_setonix)

### Georgie’s Workflow

[Clara Parabricks v4.0.1](https://docs.nvidia.com/clara/parabricks/4.0.1/index.html)

# Benchmarking

### Compare VCFs

**[hap.py](http://hap.py) - Haplotype VCF comparison**

[GitHub - Illumina/hap.py: Haplotype VCF comparison tools](https://github.com/Illumina/hap.py)

# Variant Filtering

**slivar**

[GitHub - brentp/slivar: genetic variant expressions, annotation, and filtering for great good.](https://github.com/brentp/slivar)

**GENMOD**

[GitHub - Clinical-Genomics/genmod: Annotate models of genetic inheritance patterns in variant files (vcf files)](https://github.com/Clinical-Genomics/genmod)
