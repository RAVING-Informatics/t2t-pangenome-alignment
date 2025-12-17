## MAPPING QUALITY 
### **`samtools stats`**

Run `samtools stats` on the mapped `BAM` files output from `sarek`.
Use the use the `samtools_submit_all.sh` script to specify the location of the `BAM` files. This script will iterate through and submit individual jobs for each in combination with `samtools_stats.sh`.
- Alternatively, samtools stats is run as part of the `sarek/nfcore` workflow, with individual results stored in `./reports/samtools/`.

**Inputs**
- CHM13 Mapped BAMs: `/Volumes/PERKINS-LL-001/Sequencing/wgs/secondary/T2T_realignment/batch_1/chm13/preprocessing/mapped`
- GRCh38 Mapped BAMs: `/Volumes/PERKINS-LL-001/Sequencing/wgs/secondary/T2T_realignment/batch_1/grch38/preprocessing/mapped`

**Outputs**
- Results for this project are available on the IRDS:
  - CHM13: `/Volumes/PERKINS-LL-001/Sequencing/wgs/secondary/T2T_realignment/batch_1/chm13/reports/samtools`
  - GRCh38: `/Volumes/PERKINS-LL-001/Sequencing/wgs/secondary/T2T_realignment/batch_1/grch38/reports/samtools`
- Multiqc reports for this project available at: 
  - chm13: `/Volumes/PERKINS-LL-001/Sequencing/wgs/secondary/T2T_realignment/batch_1/chm13/multiqc/multiqc_report.html`
  - grch38: `/Volumes/PERKINS-LL-001/Sequencing/wgs/secondary/T2T_realignment/batch_1/grch38/multiqc/multiqc_report.html`

**Results**
- Use the multiqc report to extract out useful metric, including the number of mapped / unmapped reads.
  - Export the `samtools-stats-dp` data. See examples [`linear_sarek_chm13_samtools-stats-dp.tsv`](https://github.com/RAVING-Informatics/T2T-alignment/blob/main/benchmarking/mapping/linear_sarek_chm13_samtools-stats-dp.tsv) and [`linear_sarek_grch38_samtools-stats-dp.tsv`](https://github.com/RAVING-Informatics/T2T-alignment/blob/main/benchmarking/mapping/linear_sarek_grch38_samtools-stats-dp.tsv)
- Manipulate data in excel to calculate mapping statistics for each sample. See excel template [`linear_t2t-hg38_mapping_calculations.xlsx`](https://github.com/RAVING-Informatics/T2T-alignment/blob/main/benchmarking/mapping/linear_t2t-hg38_mapping_calculations.xlsx) and [`linear_t2t-hg38_mapping.tsv`](https://github.com/RAVING-Informatics/T2T-alignment/blob/main/benchmarking/mapping/linear_t2t-hg38_mapping.csv) for result. 
  - Proportion reads unmapped = reads unmapped / total reads
  - Proportion reads mapped = reads mapped / total reads
  - Proportion reads MQ0 = MQ0 reads / total reads
  - Proportion properly paired = reads properly paired bit set / total reads
  - Proportion misoriented reads = read pairs with other orientation / total reads

## VARIANT QUALITY
### **`bcftools stats`**

Run `bcftools stats` on the deepvariant and dysgu VCFs for each sample (not the g.vcf files) using `bcftools_stats_ind.sh`. This is to generate per-sample summary statistics and also a plot of the number of variants of a certain variant quality score. See attached plot for example.

Run `bcftools stats` on the deepvariant and dysgu cohort VCFs using `bcftools_stats_cohort.sh`.

**Inputs**

- Use the individual deepvariant VCFs, i.e. `D09-468.deepvariant.vcf.gz`, and dysgu VCFs, i.e. `D09-468.sorted.cram_dysgu.vcf`.
  - CHM13 available here: `/Volumes/PERKINS-LL-001/Sequencing/wgs/secondary/T2T_realignment/batch_1/chm13/variant_calling/`
  - GRCh38 available here: `/Volumes/PERKINS-LL-001/Sequencing/wgs/secondary/T2T_realignment/batch_1/grch38/variant_calling/`
- Use the cohort deepvariant callsets, i.e. `T2T_dv_glnexus_VEP.ann.vcf.gz`, and cohort dysgu variants, i.e. `dysgu_merge_T2T_VEP.ann_fixed.vcf.gz`
  - CHM13 available here: `/Volumes/PERKINS-LL-001/Sequencing/wgs/secondary/T2T_realignment/batch_1/chm13/merge`
  - GRCh38 available here: `/Volumes/PERKINS-LL-001/Sequencing/wgs/secondary/T2T_realignment/batch_1/grch38/postprocess/vep` 

**Outputs**

- bcftools files are available on the IRDS.  
  - chm13: `/Volumes/PERKINS-LL-001/Sequencing/wgs/secondary/T2T_realignment/batch_1/chm13/reports/bcftools_v1.15/`
  - grch38 `/Volumes/PERKINS-LL-001/Sequencing/wgs/secondary/T2T_realignment/batch_1/grch38/reports/bcftools/`

**Results**

1. Frequency plot of variant quality.
- Use the R script, `plot_variant_quality_cohort.R` to generate a multifaceted plot of variant quality, subsetted according to particular variant subsets:
  - Genome-wide: genome variants (no filters)
  - Exome: exomic variants
  - Syntenic: variants in regions of CHM13 that are syntenic to GRCh38
  - Genome mask: variants in technically reliable regions accessible using short read mapping
  - ClinVar: variants described in ClinVar 
- Instructions to generate filtered VCFs are available below.
- Once the filtered VCFs are available, run `bcftools_stats_cohort.sh` to generate bcftools stats on each. Use `multiqc` to generate a report combining all files, and download the `bcftools_stats_vqc.tsv` data.
- Use the functions in R script: `parse_bcftools_stats_vqc.R` to convert the data into a format that is easier to plot.
- Plot data with quality scores on x-axis and number of variants on y-axis using `plot_variant_quality_cohort.R`

### Filter VCFs

**Coding regions**

To view variant quality scores for the exome, subset the cohort VCF file to include only exons using a genome annotation file:

- T2T-CHM13:
```
wget https://s3-us-west-2.amazonaws.com/human-pangenomics/T2T/CHM13/assemblies/annotation/chm13.draft_v2.0.gene_annotation.gff3
```
- GRCh38:
```
wget https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_35/gencode.v35.annotation.gff3.gz
```

```
#create bed file to include only exons
zgrep "protein_coding" $gtf | awk '$3 == "exon" {print $1"\t"$4-1"\t"$5}' > protein_coding_{genome}.bed
# use bcftools view to subset vcf to only exons and index output
bcftools view -R protein_coding_chm13.bed -Oz -o hprc-v1.1-mc-chm13_dv_glnexus_VEP.gff.exons.vcf.gz hprc-v1.1-mc-chm13_dv_glnexus_VEP.ann.vcf.gz
tabix -p vcf hprc-v1.1-mc-chm13_dv_glnexus_VEP.gff.exons.vcf.gz
```

**Clinvar Variants**

To view variant quality scores for clinvar variants, intersect the cohort VCF file with clinvar variants:

- T2T-CHM13:
```
wget https://s3-us-west-2.amazonaws.com/human-pangenomics/T2T/CHM13/assemblies/annotation/liftover/chm13v2.0_ClinVar20220313.vcf.gz
```
- GRCh38:
```
wget https://ftp.ncbi.nlm.nih.gov/pub/clinvar/vcf_GRCh38/weekly/clinvar_20220313.vcf.gz
```
Modify the GRCh38 Clinvar VCF to include only variants that could be lifted over to T2T-CHM13:
```
bcftools query -f '%ID\n' chm13v2.0_ClinVar20220313.vcf.gz | sort | uniq > chm13v2.0_ClinVar.ids
bcftools query -f '%ID\n' clinvar_20220313.vcf.gz | sort | uniq > grch38_ClinVar.ids
comm -12 grch38_ClinVar.ids chm13v2.0_ClinVar > common.ids
bcftools view -i 'ID=@common.ids' clinvar_20220313.vcf.gz -Oz -o common_clinvar_20220313.vcf.gz
bcftools view -H common_clinvar_20220313.vcf.gz | wc -l
>1113862
bcftools view -H chm13v2.0_ClinVar20220313.vcf.gz | wc -l
1113862
```
Intersect the clinvar variants with the variant callsets using `intersect_clinvar.sh`

**Masked Regions**

To view the variant quality scores for variants in technically reliable regions accessible using short read mapping, download the short-read accessibility mask:

```
wget https://s3-us-west-2.amazonaws.com/human-pangenomics/T2T/CHM13/assemblies/annotation/accessibility/combined_mask.bed
https://s3-us-west-2.amazonaws.com/human-pangenomics/T2T/CHM13/assemblies/annotation/accessibility/hg38.combined_mask.bed.gz
gzip -d hg38.combined_mask.bed.gz
```
Intesect the cohort VCF file with the mask using the `intersect_mask.sh` script. 

**Syntenic Regions**

To view the variant quality scores for variants in regions of CHM13 that are syntenic to GRCh38, download the regions that are non-syntenic between GRCh38 and CHM13:

```
wget https://s3-us-west-2.amazonaws.com/human-pangenomics/T2T/CHM13/assemblies/chain/v1_nflo/chm13v2-unique_to_hg38.bed
```

Use the script `syntenic_regions.sh` to generate a cohort VCF containing only syntenic variants. 

### **Mendelian Violations**

Calculate mendelian-violation rate using GATK `VariantEval MendelianViolationEvaluator`

*Inputs*

Use the cohort deepvariant callsets annotated with VEP: 
- `/Volumes/PERKINS-LL-001/Sequencing/wgs/secondary/T2T realignment/variant_calling/glnexus/sarek_vep_glnexus/annotation/glnexus/joint_variant_calling/T2T_dv_glnexus_VEP.ann.vcf.gz`
- `/Volumes/PERKINS-LL-001/Sequencing/wgs/secondary/T2T realignment/hg38_realignment/sarek_bwamem2_run2/annotated/dv_glnexus_VEP.ann.vcf.gz`

*Setup Instructions*

Pull the singularity image from docker hub
```
singularity pull docker://broadinstitute/gatk@sha256:71b17ee42d149e8ec112603f5305c873ab60d93949ef8bb62a4fff85427f56fb
```

*Run Script*

`gatk_mendel.sh`

### **PASS Variants**

Use `bcftools view` to count the number of PASS variants were called by Dysgu for each sample + the joint-called cohort. 

Use the `pass_variants_dysgu.sh` script.
