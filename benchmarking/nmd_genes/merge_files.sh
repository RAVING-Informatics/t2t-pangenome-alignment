#!/bin/bash

#SBATCH --job-name=merge
#SBATCH --account=pawsey0933
#SBATCH --partition=work
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=64G #8G for subsequent runs  
#SBATCH --nodes=1
#SBATCH --time=6:00:00 #0:15:00 for subsequent runs
#SBATCH --mail-user=chiara.folland@perkins.org.au
#SBATCH --mail-type=END
#SBATCH --error=%j.%x.err
#SBATCH --output=%j.%x.out
#SBATCH --export=ALL

gene='FRG2'
interval="chr4:193392576-193395463"
ref=chm13
python=/scratch/pawsey0933/cfolland/mosdepth/results

cd /scratch/pawsey0933/cfolland/mosdepth/results/collect_coverage_perbase.py

module load samtools/1.15--h3843a85_0
source /software/projects/pawsey0933/cfolland/miniconda3/etc/profile.d/mamba.sh

python3 $python $gene $interval *.$ref.per-base.bed.gz --index --threads 8 --end-inclusive -o $gene.perbase_mosdepth_$ref.tsv
