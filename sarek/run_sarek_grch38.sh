#!/bin/bash -l

#SBATCH --nodes=1
#SBATCH -c 2
#SBATCH --job-name=sarek_bwamem2
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

module load singularity/4.1.0-slurm
module load nextflow/23.10.0

nextflow run nf-core/sarek \
	-profile singularity,pawsey_setonix \
	-config /software/projects/pawsey0933/gmonahan/T2T/bam2fastq/pawsey_setonix.config \
	-resume \
        --input /software/projects/pawsey0933/gmonahan/T2T/hg38/sarek_samplesheet.csv \
        --aligner bwa-mem2 \
        --save_mapped \
        --genome null \
        --skip_tools markduplicates,baserecalibrator,vcftools \
        --igenomes_ignore \
	--tools deepvariant,cnvkit \
	--fasta /software/projects/pawsey0933/sv/references/hg38_masked/Homo_sapiens_assembly38_masked.fasta \
	--fasta_fai /software/projects/pawsey0933/sv/references/hg38_masked/Homo_sapiens_assembly38_masked.fasta.fai \
	--bwamem2 /software/projects/pawsey0933/sv/references/hg38_masked/ \
	--outdir /scratch/pawsey0933/T2T/hg38_realignment/sarek_bwamem2
