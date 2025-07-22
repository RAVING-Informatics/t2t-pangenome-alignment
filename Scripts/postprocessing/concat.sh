#!/bin/bash -l

#SBATCH --nodes=1
#SBATCH -c 6                          
#SBATCH --job-name=concat_t2t
#SBATCH --partition=work
#SBATCH --account=pawsey0933
#SBATCH --mem=16G
#SBATCH --time=2:00:00
#SBATCH --mail-user=chiara.folland@perkins.org.au
#SBATCH --mail-type=END
#SBATCH --error=%j.%x.err
#SBATCH --output=%j.%x.out
#SBATCH --export=ALL

# Load modules
module load bcftools/1.15--haf5b3da_0

# Define variables
ref=chm13
#ref=grch38
dv=/scratch/pawsey0933/cfolland/benchmark/vcfs/deepvariant/linear/cohort/T2T_dv_glnexus_VEP.ann.vcf.gz
#dv=/scratch/pawsey0933/cfolland/vep/annotation/glnexus/merged-dv/dv_glnexus_VEP.ann.vcf.gz
dysgu=/scratch/pawsey0933/cfolland/benchmark/vcfs/dysgu/linear/dysgu_merge_T2T_VEP.ann.vcf.gz
#dysgu=/scratch/pawsey0933/cfolland/benchmark/vcfs/dysgu/linear/dysgu_merge_hg38_VEP.ann.vcf.gz
outdir=/scratch/pawsey0933/cfolland/t2t/vcfs/

# Concatenate, sort and index
bcftools concat -a -Oz --threads 12 -o $outdir/linear_${ref}_dv_dysgu_VEP_concat.vcf.gz $dv $dysgu
#bcftools index -t $outdir/hprc-v1.1-mc-${ref}_dv_dysgu_VEP_concat.vcf.gz
bcftools sort -T $outdir -o $outdir/linear_${ref}_dv_dysgu_VEP_sorted.vcf.gz $outdir/linear_${ref}_dv_dysgu_VEP_concat.vcf.gz 
#bcftools index -t $outdir/hprc-v1.1-mc-${ref}_dv_dysgu_VEP_sorted.vcf.gz
bcftools view -e 'CSQ[*]="."' $outdir/linear_${ref}_dv_dysgu_VEP_sorted.vcf.gz -Oz -o $outdir/linear_${ref}_dv_dysgu_VEP_sorted_noCSQ.vcf.gz
bcftools index -t $outdir/linear_${ref}_dv_dysgu_VEP_sorted_noCSQ.vcf.gz
