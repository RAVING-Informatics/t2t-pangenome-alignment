#!/bin/bash

# this script annotates pangenome vcfs

module load singularity 
module load java 
module load htslib

datadir=/scratch/iz89/reference/t2t
gff_bed=/scratch/iz89/reference/t2t/T2T-CHM13v2.0_genes_sorted.bed

# prepare gene annotations - this step was run by T2T-scripts
bedops=/scratch/er01/PIPE-4135-CMT_neurogenomics/300_preprocessing/T2T-scripts/singularity_cache/bedops_2.4.41--h4ac6f70_1.sif

# sort and extract genes from GTF - this step was run by T2T-scripts
zcat ${datadir}/chm13v2.0_GENCODEv35_CAT_Liftoff.vep.gff3.gz | grep "^#" > ${datadir}/header.gff
zcat ${datadir}/chm13v2.0_GENCODEv35_CAT_Liftoff.vep.gff3.gz | awk '$3 == "gene"' | sort -k1,1 -k4,4n > ${datadir}/sorted.gff

# generate subset sorted GTF - this step was run by T2T-scripts
cat ${datadir}/header.gff ${datadir}/sorted.gff > ${datadir}/chm13v2.0_GENCODEv35_genes_sorted.gff

#cleanup - this step was run by T2T-scripts
rm ${datadir}/header.gff ${datadir}/sorted.gff

# convert sorted gene only gtf to bed - this step was run by T2T-scripts
singularity run -B /scratch/er01 -B /scratch/iz89 \
    ${bedops} gff2bed < ${datadir}/chm13v2.0_GENCODEv35_genes_sorted.gff > ${gff_bed}

# zip and index - this step was run by T2T-scripts
bgzip ${gff_bed}
tabix ${gff_bed}.gz

# annotate vcf with genes 
vcf_dir=/scratch/er01/PIPE-4135-CMT_neurogenomics/500_out_data/Pangenome
samples=(54_950151 CMT714 CMT720 FD07779187 FS28687775)

for sample in "${samples[@]}"; do

    anno_vcf=${vcf_dir}/${sample}/${sample}_pangenome_anno.vcf
    vcfanno=/scratch/er01/PIPE-4135-CMT_neurogenomics/300_preprocessing/T2T-scripts/singularity_cache/vcfanno_0.3.3--h9ee0642_0.sif
    
    # rehead vcfs 
    echo ${sample} > ${sample}.txt
    bcftools reheader -s ${sample}.txt -o ${pangenomes}/${sample}_genotyping_biallelic_rehead.vcf \
        ${pangenomes}/${sample}_genotyping_biallelic.vcf.gz

    bgzip ${pangenomes}/${sample}_genotyping_biallelic_rehead.vcf
    tabix ${pangenomes}/${sample}_genotyping_biallelic_rehead.vcf

    # annotate with gtf
    gunzip ${vcf_dir}/${sample}/${sample}_genotyping_biallelic_rehead.vcf.gz

    singularity run -B /scratch/er01 -B /scratch/iz89 \
        ${vcfanno} vcfanno -p 4 CHM13-T2T.toml ${vcf_dir}/${sample}/${sample}_genotyping_biallelic_rehead.vcf \
        > ${anno_vcf}

    # bgzip and index vcf 
    bgzip ${anno_vcf}
    tabix ${anno_vcf}.gz

done