#!/bin/bash -l

#SBATCH --nodes=1
#SBATCH -c 1
#SBATCH --job-name=bam2fq
#SBATCH --partition=work
#SBATCH --account=pawsey0933
#SBATCH --mem=4gb
#SBATCH --time=1-00:00:00
#SBATCH --export=NONE
#SBATCH --mail-user=gavin.monahan@perkins.org.au
#SBATCH --mail-type=END
#SBATCH --error=%j.%x.err
#SBATCH --output=%j.%x.out

export NXF_WORK=/scratch/pawsey0933/T2T
export NXF_OPTS='-Xms1g -Xmx4g'

module load singularity/3.11.4-slurm
module load nextflow/23.10.0

nextflow run nf-core/bamtofastq \
	-profile singularity,pawsey_setonix \
	-resume \
	--input /software/projects/pawsey0933/gmonahan/T2T/bam2fastq.csv \
	--fasta /software/projects/pawsey0933/sv/references/hg38_masked/Homo_sapiens_assembly38_masked.fasta \
	--fasta_fai /software/projects/pawsey0933/sv/references/hg38_masked/Homo_sapiens_assembly38_masked.fasta.fai \
	--outdir /scratch/pawsey0933/T2T/fastq
