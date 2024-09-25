#!/bin/bash -l

#SBATCH --job-name=pangenie-index
#SBATCH --account=pawsey0933
#SBATCH --partition=work
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --nodes=1
#SBATCH --time=1:00:00
#SBATCH --mail-user=chiara.folland@perkins.org.au
#SBATCH --mail-type=END
#SBATCH --error=%j.%x.err
#SBATCH --output=%j.%x.out
#SBATCH --export=ALL

#load modules
module load singularity/4.1.0-slurm

cd /scratch/pawsey0933/cfolland/pangenie/

singularity exec ./container/pangenie.sif PanGenie-index -v ./refs/chm13_cactus_filtered_ids_biallelic.vcf -r ./refs/CHM13v11Y.fa -t 24 -o index
singularity exec ./container/pangenie.sif PanGenie-index -v ./refs/chm13_cactus_filtered_ids.vcf -r ./refs/CHM13v11Y.fa -t 24 -o index
