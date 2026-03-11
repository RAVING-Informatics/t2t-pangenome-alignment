#!/bin/bash -l

#SBATCH --nodes=1
#SBATCH -c 2
#SBATCH --job-name=sarek_align
#SBATCH --partition=work
#SBATCH --account=pawsey0933
#SBATCH --mem=20gb
#SBATCH --time=1-00:00:00
#SBATCH --export=NONE
#SBATCH --mail-user=gavin.monahan@perkins.org.au
#SBATCH --mail-type=END
#SBATCH --error=%j.%x.err
#SBATCH --output=%j.%x.out

export NXF_WORK=/scratch/pawsey0933/T2T
export NXF_OPTS='-Xms1g -Xmx19g'

module load singularity/3.11.4-slurm
module load nextflow/23.10.0

nextflow run nf-core/sarek \
	-profile singularity,pawsey_setonix \
	-resume \
	--input /software/projects/pawsey0933/gmonahan/T2T/sarek_samplesheet.csv \
	--aligner dragmap \
	--save_mapped \
	--genome null \
	--skip_tools baserecalibrator \
	--igenomes_ignore \
	--fasta /scratch/pawsey0933/T2T/reference/chm13v2.0.maskedY.rCRS.EBV.fasta \
	--fasta_fai /scratch/pawsey0933/T2T/reference/chm13v2.0.maskedY.rCRS.EBV.fasta.fai \
	--outdir /scratch/pawsey0933/T2T/sarek_align
