#!/bin/bash

# Load modules
module load singularity
module load bcftools/1.12
module load htslib

# Set variables 
sample=`echo $1 | cut -d ',' -f 1`
fqs=`echo $1 | cut -d ',' -f 2`
image_dir=/scratch/iz89/gm1516
image_name=/scratch/iz89/gm1516/pangenie.sif
ref=/scratch/iz89/gm1516/ref/CHM13v11Y.fa
graph_vcf=/scratch/iz89/gm1516/ref/chm13_cactus_filtered_ids_biallelic.vcf
outdir=/scratch/er01/PIPE-4135-CMT_neurogenomics/500_out_data/Pangenome
decomp_script=/scratch/iz89/PIPE-4135-CMT_neurogenomics/300_preprocessing/Pangenie-scripts/convert-to-biallelic.py

# Run pangenie
singularity exec -B /scratch/er01,/scratch/iz89 ${image_name} PanGenie \
    -i <(zcat $fqs) \
    -r ${ref} \
    -v ${graph_vcf} \
    -t 23 \
    -j 23 \
    -o ${outdir}/${sample}

# Decompose bubbles 
cat ${outdir}/${sample}_genotyping.vcf | python3 ${decomp_script} ${graph_vcf} \
    > ${outdir}/${sample}_genotyping_biallelic.vcf

# Collect vcf stats 
bcftools stats ${outdir}/${sample}_genotyping_biallelic.vcf > ${outdir}/${sample}_genotyping_biallelic.stats