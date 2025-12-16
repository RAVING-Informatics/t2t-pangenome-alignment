#!/bin/bash -l

#SBATCH --nodes=1
#SBATCH -c 2
#SBATCH --job-name=sarek_bwamem2
#SBATCH --partition=work
#SBATCH --account=pawsey0933
#SBATCH --mem=20gb
#SBATCH --time=1-00:00:00
#SBATCH --export=NONE
#SBATCH --mail-user=chiara.folland@perkins.org.au
#SBATCH --mail-type=END
#SBATCH --error=%j.%x.err
#SBATCH --output=%j.%x.out

export NXF_WORK=/scratch/pawsey0933/cfolland/t2t/nfcore
export SINGULARITY_CACHEDIR=/scratch/pawsey0933/cfolland/.singularity
export NXF_OPTS='-Xms1g -Xmx19g'

module load singularity/4.1.0-slurm
module load nextflow/24.10.0

nextflow run nf-core/sarek \
	-r 3.4.0 \
	-profile singularity,pawsey_setonix \
	-config /software/projects/pawsey0933/t2t/sarek/pawsey_setonix.config \
    -resume \
    --input /software/projects/pawsey0933/t2t/sarek/samplesheet_batch_garvan.csv \
    --aligner bwa-mem2 \
    --save_mapped \
    --genome null \
    --skip_tools markduplicates,baserecalibrator,vcftools \
    --igenomes_ignore \
	--tools deepvariant,manta,tiddit,cnvkit \
	--fasta /software/projects/pawsey0933/pangenome/refs/chm13v2.0.maskedY.rCRS.EBV.fasta  \
	--fasta_fai /software/projects/pawsey0933/pangenome/refs/chm13v2.0.maskedY.rCRS.EBV.fasta.fai \
	--bwamem2 /scratch/pawsey0933/cfolland/t2t/nfcore/57/acfde7c69ad0f4b5be0889b1767d8d/bwamem2 \
	--save_reference \
	--outdir /scratch/pawsey0933/cfolland/t2t/nfcore/sarek_bwamem2
