#!/bin/bash

input_file=/software/projects/pawsey0933/pangenie/samplesheet/01_t2t_samplesheet.csv

# Variable to store the previous job ID
previous_job_id=""

#Define variables
ref=/scratch/pawsey0933/cfolland/pangenie/refs/CHM13v11Y.fa
graph_vcf=/software/projects/pawsey0933/pangenie/refs/chm13_cactus_filtered_ids_biallelic.vcf
outdir=/scratch/pawsey0933/cfolland/pangenie/output/t2t
decomp_script=/software/projects/pawsey0933/pangenie/scripts_gs/convert-to-biallelic.py

# Loop through the CSV file, skipping the header

awk -F, 'NR>1 {print $1, $2, $3}' $input_file | while read -r sample fq1 fq2; do
    echo "Submitting job for sample: $sample"

    if [ -z "$previous_job_id" ]; then
        # Submit the first job without dependency
        job_id=$(sbatch <<EOF | awk '{print $4}'
#!/bin/bash
#SBATCH --job-name=pangenie_$sample
#SBATCH --account=pawsey0933
#SBATCH --partition=work
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=23
#SBATCH --mem=80G
#SBATCH --nodes=1
#SBATCH --time=12:00:00
#SBATCH --output=${sample}_%j.out
#SBATCH --error=${sample}_%j.err

#Load modules
module load singularity/4.1.0-slurm
module load bcftools/1.15--haf5b3da_0
module load samtools/1.15--h3843a85_0

# Pangenie genotyping
singularity exec -B /scratch/pawsey0933/cfolland/pangenie /software/projects/pawsey0933/pangenie/container/pangenie.sif PanGenie \
 -f /scratch/pawsey0933/cfolland/pangenie/index/index \
 -i <(zcat ${fq1} ${fq2}) \
 -s ${sample} \
 -t 23 \
 -j 23 \
 -o ${outdir}/${sample}

# Decompose bubbles
cat ${outdir}/${sample}_genotyping.vcf | python3 ${decomp_script} ${graph_vcf} \
> ${outdir}/${sample}_genotyping_biallelic.vcf

# Collect vcf stats
bcftools stats ${outdir}/${sample}_genotyping_biallelic.vcf > ${outdir}/${sample}_genotyping_biallelic.stats

EOF
)
    else
        # Submit subsequent jobs with a dependency on the previous job
        job_id=$(sbatch --dependency=afterok:$previous_job_id <<EOF | awk '{print $4}'
#!/bin/bash
#SBATCH --job-name=pangenie_$sample
#SBATCH --account=pawsey0933
#SBATCH --partition=work
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=23
#SBATCH --mem=80G
#SBATCH --nodes=1
#SBATCH --time=12:00:00
#SBATCH --output=${sample}_%j.out
#SBATCH --error=${sample}_%j.err

# Load modules
module load singularity/4.1.0-slurm
module load bcftools/1.15--haf5b3da_0
module load samtools/1.15--h3843a85_0

# Pangenie genotyping
singularity exec -B /scratch/pawsey0933/cfolland/pangenie /software/projects/pawsey0933/pangenie/container/pangenie.sif PanGenie \
 -f /scratch/pawsey0933/cfolland/pangenie/index/index \
 -i <(zcat ${fq1} ${fq2}) \
 -s ${sample} \
 -t 23 \
 -j 23 \
 -o ${outdir}/${sample}

# Decompose bubbles
cat ${outdir}/${sample}_genotyping.vcf | python3 ${decomp_script} ${graph_vcf} \
> ${outdir}/${sample}_genotyping_biallelic.vcf

# Collect vcf stats
bcftools stats ${outdir}/${sample}_genotyping_biallelic.vcf > ${outdir}/${sample}_genotyping_biallelic.stats
EOF
)
    fi

    # Update the previous job ID to the current one
    previous_job_id=$job_id

done
