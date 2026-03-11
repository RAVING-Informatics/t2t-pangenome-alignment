# Genotyping with PanGenie

Pangenie was run according to [developer recommendations](https://github.com/eblerjana/pangenie/wiki/D:-Running-PanGenie-on-HPRC-data) for the CHM13-T2T assembly. 

### Install pangenie

Installation instructions for **PanGenie** are available [here](https://github.com/eblerjana/pangenie). For this project, we used the Singularity image provided by the developer:

1. [Download the container to your local computer](https://github.com/eblerjana/pangenie/blob/master/container/pangenie.def) 

2. Build the container with Singularity:

```bash
singularity build pangenie.sif pangenie.def 
```

### Prepare reference data

The **reference** fasta we used for our analysis is available [here](https://s3-us-west-2.amazonaws.com/human-pangenomics/pangenomes/freeze/freeze1/minigraph/CHM13v11Y.fa.gz).

1. Download the input graph VCF for PanGenie v2.1.1 (HPRC-CHM13 (88 haplotypes)) from [here](https://github.com/eblerjana/pangenie/wiki/D:-Running-PanGenie-on-HPRC-data) with: 

```bash
wget https://zenodo.org/record/7839719/files/chm13_cactus_filtered_ids.vcf.gz
wget https://zenodo.org/record/7839719/files/chm13_cactus_filtered_ids_biallelic.vcf.gz
```

2. Download and decompress the reference assembly 

```bash
# download fasta 
wget https://s3-us-west-2.amazonaws.com/human-pangenomics/pangenomes/freeze/freeze1/minigraph/CHM13v11Y.fa.gz

# unzip 
gunzip CHM13v11Y.fa.gz
```

### Run pangenie 

1. Index the reference fasta and graph VCF 

```bash
PanGenie-index -v <graph-vcf> -r <reference-genome> -t 24 -o index
```

2. Make config file (same as for T2T-scripts)

The .config file is *comma-delimited* text file that tells the scripts which samples to process, and where it can locate relevant fastq files. The header line must start with `#`. Samples with >1 fq pairs can be organised into separate rows for each fq pair, as specified in example below:

|#sample,fq1,fq2,platform,library,center|
|-------------------------------------------------------------------------|
|sample1,/path/to/sample_R1.fq.gz,/path/to/sample_R2.fq.gz,Illumina,1,KCGG|
|sample2,/path/to/sample2_lane1_R1.fq.gz,/path/to/sample2_lane1_R2.fq.gz,Illumina,1,KCGG|
|sample2,/path/to/sample2_lane2_R1.fq.gz,/path/to/sample2_lane2_R2.fq.gz,Illumina,1,KCGG|

3. Download Pangenie code base

```bash
wget https://github.com/eblerjana/pangenie.git
```

4. Run pangenie on each sample to produce genotype VCFs 

These scripts were written to run as array jobs on NCI Gadi, where the #PBS -j variable is not available for us. 

**Make inputs** 

This script generates an input file for `pangenie.sh` which runs Pangenie in parallel for all samples in the config. Samples with multiple fastq pairs will be accounted for when generating this input file. Once this script is run, it will generate an input text file at `./Inputs/pangenie.inputs`. 

```bash 
bash pangenie_make_input.sh /path/to/config
```

**Run parallel**

This script automatically picks up the previously created `./Inputs/pangenie.inputs` file and runs `pangenie.sh` for each of them. Before running you'll need to adjust the PBS directives based on your project and number of samples to be processed: 

* #PBS -P your gadi project code
* #PBS -l ncpus= (24 * number of samples)
* #PBS -l mem= (190GB * number of normal nodes)
* #PBS -l storage=gdata/if89+scratch/gadi-project-code

You'll also need to customise paths to your reference assembly and the `convert_to_biallelic.py` script provided in the [Pangenie code base](https://github.com/eblerjana/pangenie/blob/master/pipelines/run-from-callset/scripts/convert-to-biallelic.py).

#### Perform genotype quality control 

Quality metrics for each sample genotype were generated using BCFtools. The following script was executed: 

```bash
pangenome_stats.sh
```

This script: 
* Extracts heterozygous and homozygous alt variants from each sample biallelic vcf
* Runs bcftools stats over each sample's vcf to confirm improvement in quality 
* Generate per-sample quality metrics 

### Apply gene annotations 

Instructions for how the GFF3 file was sourced and prepared for annotations is described in `T2T-scripts`. To run annotations for Pangenome scripts, run:

```bash
bash variant_annotate.sh
```

This is the `.toml` file applied to the CMT cohort:

```bash
[[annotation]]
file="/scratch/er01/reference/t2t/T2T-CHM13v2.0_genes_sorted.bed.gz"
columns = [10]
names = ["Gene"]
ops = ["concat"]
```