**`samtools stats`**

Run `samtools stats` on the mapped `BAM` files output from `sarek`.
Use the use the `samtools_submit_all.sh` script to specify the location of the `BAM` files. This script will iterate through and submit individual jobs for each in combination with `samtools_stats.sh`.

**`bcftools stats`**

Run `bcftools stats` on the deepvariant and dysgu VCFs for each sample (not the g.vcf files). 

This is to generate a plot of the number of variants of a certain variant quality score. See attached plot for example.

*Inputs*

- Use the individual deepvariant VCFs i.e. `D09-468.deepvariant.vcf.gz`
- Use the cohort deepvariant callsets for comparison with coding variants / clinvar variants (see below) i.e. `T2T_dv_glnexus_VEP.ann.vcf.gz`

*Results*

- Use multiqc to generate a report of the bcftools stats, and download the `bcftools_stats_vqc.tsv` data.
- Use the R script: `parse_quality_scores.R` to convert the data into a format that is easier to plot.
- Plot data to represent quality scores on x-axis and number of variants on y-axis.
- Normalise data by dividing by the total number of variants in each dataset.

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

**Mendelian Violations**

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

**PASS Variants**

Use `bcftools view` to count the number of PASS variants were called by Dysgu for each sample + the joint-called cohort. 

Use the `pass_variants_dysgu.sh` script.
