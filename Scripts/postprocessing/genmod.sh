#!/bin/bash -l

#SBATCH --nodes=1
#SBATCH -c 1
#SBATCH --job-name=genmod
#SBATCH --partition=work
#SBATCH --account=pawsey0933
#SBATCH --mem=180G
#SBATCH --time=12:00:00
#SBATCH --mail-user=chiara.folland@perkins.org.au
#SBATCH --mail-type=END
#SBATCH --error=%j.%x.err
#SBATCH --output=%j.%x.out
#SBATCH --export=ALL

input_dir=/scratch/pawsey0933/cfolland/t2t/batch2/chm13
ped=/software/projects/pawsey0933/t2t/scripts/batch2.new.ped
input=batch2_linear_chm13_dv_dysgu_VEP.sorted.noCSQ.vcf.gz
output=batch2_linear_chm13_dv_dysgu_VEP.sorted.noCSQ.genmod.vcf.gz

source /scratch/pawsey0933/cfolland/anaconda3/etc/profile.d/mamba.sh
mamba activate /software/projects/pawsey0933/cfolland/miniforge3/envs/genmod

genmod models --vep -f $ped -o $input_dir/$output $input_dir/$input
