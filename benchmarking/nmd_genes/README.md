## Generate a .BED file containing coordinates for NMD genes

1) Source a list of genes associated with neuromuscular diseases. I used the list of genes run on the [PathWest neuromuscular gene panel](https://pathwest.health.wa.gov.au/Our-Services/Clinical-Services/Diagnostic-Genomics/Neurogenetics)
- This encompasses 912 genes, and FRG1 and FRG2 were added manually : `nmd_gene_list.tsv`

2) Source the appropriate annotation files
- I used the RefSeq annotation from 2025_08.
  - GRCh38 available [here](https://ftp.ncbi.nlm.nih.gov/refseq/H_sapiens/annotation/annotation_releases/)
  - CHM13 available [here](https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/009/914/755/GCF_009914755.1_T2T-CHM13v2.0/)
```
# chm13
wget https://ftp.ncbi.nlm.nih.gov/refseq/H_sapiens/annotation/annotation_releases/GCF_009914755.1-RS_2025_08/GCF_009914755.1_T2T-CHM13v2.0_genomic.gtf.gz
# this corresponds to ensembl v110 release for hg38
wget https://ftp.ncbi.nlm.nih.gov/refseq/H_sapiens/annotation/annotation_releases/GCF_000001405.40-RS_2025_08/GCF_000001405.40_GRCh38.p14_genomic.gtf.gz
```

3) Run script `gtf-bed_transcripts.sh` to extract out transcripts from gtf file
- Extracting out the coordinates from the “gene” entry in the gtf file was fallible as each “gene” is defined differently across the reference builds.
- It was best therefore to extract out the transcripts, find the intersection of the transcripts described across the two reference builds, then aggregate the coordinates across the transcripts to essentially define new gene regions for each reference build.

4) Find the intersection of transcripts described across the two reference builds with `intersect.sh`

5)  Map the chromosome RefSeq IDs (NC_00#) to chromosome names (chr#)
- The new GTF files contain Refseq IDs `NC_00*` instead of chromosome names i.e. `chr1`
    - Create a mapping file for the RefSeq Ids to chromosome names: `refseq-chr_chm13.tsv`  `refseq-chr_grch38.tsv`
    - Create a new script to change the refseq ids to chromsome names in the bed file: `refseq-chr.sh`
```
$ ./refseq-chr.sh refseq-chr_grch38.tsv GCF_000001405.40_GRCh38.p14.transcripts.shared.bed GCF_000001405.40_GRCh38.p14.transcripts.shared.fixed.bed
```

6) Use `aggregate_genes.sh` to aggregate across transcripts and define a new gene coordinate set for each reference genome bed file

```
$ ./aggregate_genes.sh GCF_000001405.40_GRCh38.p14.transcripts.shared.fixed.bed GCF_000001405.40_GRCh38.p14.genes_aggregate.bed
```
7) Filter bed file to include only NMD genes: `filter.py`
- Output file: `nmd_gene_list_chm13.bed` or `nmd_gene_list_grch38.bed`
```
$ python3 filter.py
```
8) Check that the genes match across all three files:
- `nmd_gene_list_chm13.bed`
- `nmd_gene_list_grch38.bed`
- `nmd_gene_list.tsv`

**1 gene missing NDUFA4 = COXFA4 - manually copy over gene coordinates into the .bed files**

## Run Mosdepth using .BED file as input with `--by` flag
1) Download mosdepth singularity image
```
$ singularity pull quay.io/biocontainers/mosdepth:0.3.3--h37c5b7d_2
```
2) Run Mosdepth on all samples
- Batch mosdepth using `run_mosdepth.sh` script which generates individual jobs for each `.cram` file using `mosdepth.sh`

3) Collect per-base coverage for a specific gene/interval of interest
The script `collect_coverage_perbase.py` extracts the per-gene coverage for a single genomic interval from many per-base mosdepth outputs and writes a single long-format table:
`gene	chr	start	end	sample	depth`
The script can be run easy using `merge_files.sh`. The first time this script is run, lots of resources are needed as the python script will index the per-base.bed.gz files before extracting the depth metrics. After the first run, the time and memory allocations can be reduced significantly.
   
