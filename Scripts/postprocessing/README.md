These postprocessing scripts are to be used on the cohort VCF produced after running Sarek. 

Step 1 ) Annotate cohort frequencies from control populations
- 3202 srGS samples from 1000 Genomes Phase 3 recalled on T2T-CHM13
- The Human Pangenome Reference Consortium (HPRC) T2T-CHM13 callset, including 44 high quality diploid human assemblies
- 76,156 srGS aligned to GRCh38 from gnomAD v3.1.2 and lifted over to T2T-CHM13

See scripts: `combined_annotation.sh`

Step 2 ) Filter out low quality variants
- Filter for PASS variants
- Filter for variants in QUAL scores >10 (for SNPs/indels and SVs called by Tiddit)
- Filter for variants with QUAL scores > 250 (for SVs called using Manta)
See script: filter_qc.sh

Step 3 ) OPTIONAL - Filter out variants with allele frequencies greater than 0.01 in gnomAD and 1000G, and variants with AC > 10 in the callset.
See script: filter_af.sh

Step 4) Create family specific VCFs
- Subset the VCF to include variants only present in a given family
- Further filter this VCF to subset into VCFs containing only variants annotated as AD or AR by genmod
See script: family.sh

Step 5} Parse the VCF files to make them readable
- This step converts the VCF files into either TSVs or CSVs which can then be analysed in Excel or another platform
- The script also extracts out useful information from the INFO field in the VCFs and assigns them as their own columns for ease of filtering
See scripts: process_vcfs.sh, parse.py




