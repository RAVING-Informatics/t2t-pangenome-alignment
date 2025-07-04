#!/bin/bash -l

#SBATCH --job-name=bcftools_stats
#SBATCH --account=pawsey0933
#SBATCH --partition=work
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=16G
#SBATCH --nodes=1
#SBATCH --time=1:00:00
#SBATCH --mail-user=chiara.folland@perkins.org.au
#SBATCH --mail-type=END
#SBATCH --error=%j.%x.err
#SBATCH --output=%j.%x.out
#SBATCH --export=NONE

#load modules
module load bcftools/1.15--haf5b3da_0

#Define variables
REF=/software/projects/pawsey0933/sv/references/hg38_masked/Homo_sapiens_assembly38_masked.fasta
#/software/projects/pawsey0933/pangenome/refs/chm13v2.0.maskedY.rCRS.EBV.fasta
INPUT_DIR=/scratch/pawsey0933/cfolland/benchmark/vcfs/dysgu/linear
#/scratch/pawsey0933/cfolland/benchmark/vcfs/deepvariant/linear/cohort
OUTPUT_DIR=/scratch/pawsey0933/cfolland/benchmark/output/linear/bcftools_stats/cohort/
PREFIX=dysgu_merge_hg38_VEP
#dysgu_merge_T2T_VEP
#T2T_dv_glnexus_VEP
#hg38_dv_glnexus_VEP
VCF=$PREFIX.ann.vcf.gz

echo "Calculating bcftools stats for $PREFIX"
OUTPUT=$OUTPUT_DIR/${PREFIX}.bcftools_stats.txt
bcftools stats $INPUT_DIR/$VCF > $OUTPUT
