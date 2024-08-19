#!/bin/bash -l

#SBATCH --job-name=pangenie
#SBATCH --account=pawsey0933
#SBATCH --partition=long
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=230G
#SBATCH --nodes=1
#SBATCH --time=48:00:00
#SBATCH --mail-user=chiara.folland@perkins.org.au
#SBATCH --mail-type=END
#SBATCH --error=%j.%x.err
#SBATCH --output=%j.%x.out
#SBATCH --export=ALL

# Load modules
module load singularity/4.1.0-slurm
module load bcftools/1.15--haf5b3da_0
module load samtools/1.15--h3843a85_0 #htslib

# Set variables 
input_file=/software/projects/pawsey0933/pangenie/samplesheet/t2t_samplesheet.csv
image_dir=/scratch/pawsey0933/cfolland/pangenie/container/
image_name=/scratch/pawsey0933/cfolland/pangenie/container/pangenie.sif
ref=/scratch/pawsey0933/cfolland/pangenie/refs/CHM13v11Y.fa
graph_vcf=/scratch/pawsey0933/cfolland/pangenie/refs/chm13_cactus_filtered_ids.vcf
outdir=/scratch/pawsey0933/cfolland/pangenie/output
decomp_script=/scratch/pawsey0933/cfolland/pangenie/scripts_gs/convert-to-biallelic.py

# Read the input file and process each sample
awk -F, 'NR>1 {print $1, $2, $3}' $input_file | while read -r sample fq1 fq2; do
    echo "Processing sample: $sample"

    # Run PanGenie
    singularity exec -B /scratch/pawsey0933/cfolland/pangenie ${image_name} PanGenie \
        -i <(zcat ${fq1} ${fq2}) \
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

done
