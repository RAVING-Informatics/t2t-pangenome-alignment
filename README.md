# T2T Re-alignment

# Release Paper

[The complete sequence of a human genome](https://www.science.org/doi/10.1126/science.abj6987)

# T2T Resources

**GitHub Repository** 

[GitHub - marbl/CHM13: The complete sequence of a human genome](https://github.com/marbl/CHM13)

**T2T Assembly Fasta File**

- `chm13v2.0.fa.gz: CHM13 v2.0 assembly`
- The CHM13v2.0 reference genome is available for download [here](https://www.notion.so/T2T-Re-alignment-d358656c0d494dd9922ed24d84d36821?pvs=21)
- It is best practice to use the masked Y, rCRS, EBV version from the [broad](https://console.cloud.google.com/storage/browser/gcp-public-data--broad-references/t2t/v2;tab=objects?pageState=(%22StorageObjectListTable%22:(%22f%22:%22%255B%255D%22))&prefix=&forceOnObjectsSortingFiltering=false)

**Genome Annotation**

- GFF/GFF files

[Index of /genomes/all/GCF/009/914/755/GCF_009914755.1_T2T-CHM13v2.0](https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/009/914/755/GCF_009914755.1_T2T-CHM13v2.0/)

- VEP cache

[ensembl rapid release](https://ftp.ensembl.org/pub/rapid-release/species/Homo_sapiens/GCA_009914755.4/ensembl/variation/2022_10/vep/)

**T2T-Aligned VCFs**

- 1000Genomes (SNPs/Indels)

[human-pangenomics](https://s3-us-west-2.amazonaws.com/human-pangenomics/index.html?prefix=T2T/CHM13/assemblies/variants/1000_Genomes_Project/chm13v2.0/all_samples_3202/)

- 1000Genomes (SVs)

[nanopore](https://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/1KG_ONT_VIENNA/)

- gnomAD v3.1.2 liftover

[Index of /pub/rapid-release/species/Homo_sapiens/GCA_009914755.4/ensembl/variation/2022_10/vcf](https://ftp.ensembl.org/pub/rapid-release/species/Homo_sapiens/GCA_009914755.4/ensembl/variation/2022_10/vcf/)

# **Pipeline / Workflow**

`sarek - nfcore`

[sarek: Introduction](https://nf-co.re/sarek/3.4.0)

### Workflow Config for Setonix

[nf-core/configs: pawsey_setonix](https://nf-co.re/configs/pawsey_setonix)

### Georgie’s Workflow

[Parabricks-Genomics-nf](https://github.com/Sydney-Informatics-Hub/Parabricks-Genomics-nf)
[Clara Parabricks v4.0.1](https://docs.nvidia.com/clara/parabricks/4.0.1/index.html)

### Pangenome genotyping workflow 

[/Scripts/Pangenie](./Scripts/Pangenie)

# Benchmarking

### Compare VCFs

**[hap.py](http://hap.py) - Haplotype VCF comparison**

[GitHub - Illumina/hap.py: Haplotype VCF comparison tools](https://github.com/Illumina/hap.py)

# Variant Filtering

**slivar**

[GitHub - brentp/slivar: genetic variant expressions, annotation, and filtering for great good.](https://github.com/brentp/slivar)

**GENMOD**

[GitHub - Clinical-Genomics/genmod: Annotate models of genetic inheritance patterns in variant files (vcf files)](https://github.com/Clinical-Genomics/genmod)
