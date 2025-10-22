1) Source a list of genes associated with neuromuscular diseases. I used the list of genes run on the [PathWest neuromuscular gene panel](https://pathwest.health.wa.gov.au/Our-Services/Clinical-Services/Diagnostic-Genomics/Neurogenetics)
- This encompasses 912 genes: `nmd_gene_list.tsv`

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
  - 
7) Filter bed file to include only NMD genes: `filter.py`

9) 
   
