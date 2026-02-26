# Allele mapping bias
Assess the mapping bias of linear (GRCh38) alignments (BWA-MEM) and GRCh38-surjected graph alignments (Giraffe and vg surject). 
Recreate the analysis of allele bias from paper ["Pangenomics enables genotyping of known structural variants in 5202 diverse genomes" (Siren et al. 2021)](https://www.science.org/doi/10.1126/science.abg8871). See [Figure 4A](https://www.science.org/doi/10.1126/science.abg8871#F4).

Use BAM/CRAM files generated previously by `nfcore/sarek` (linear, bwa-mem) and `vg_snakemake` (pangenome, giraffe). 

## Variant calling
Use `call_mpileup_giraffe_bwa.sh` to:
1. Call variants using `bcftools mpileup` and `call` in linear and pangenome alignments.
2. Merge VCFs to identify heterozygous variants common between the callsets.
3. Filter for high quality variants (`INFO/DP>=25 && INFO/MQ>=40`).

## Plotting
Use `plot_ab_mapers.py` to generate a plot showing the fraction of alternate alleles across reads for high-quality heterozygous variants, divided by allele length.
