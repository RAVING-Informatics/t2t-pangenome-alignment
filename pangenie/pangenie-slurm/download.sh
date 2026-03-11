#!/bin/bash -l

#SBATCH --job-name=pangenie
#SBATCH --account=pawsey0933
#SBATCH --partition=work
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=32G
#SBATCH --nodes=1
#SBATCH --time=1:00:00
#SBATCH --mail-user=chiara.folland@perkins.org.au
#SBATCH --mail-type=END
#SBATCH --error=%j.%x.err
#SBATCH --output=%j.%x.out
#SBATCH --export=ALL

cd /scratch/pawsey0933/cfolland/pangenie/refs
wget https://zenodo.org/record/7839719/files/chm13_cactus_filtered_ids.vcf.gz
wget https://zenodo.org/record/7839719/files/chm13_cactus_filtered_ids_biallelic.vcf.gz
wget https://s3-us-west-2.amazonaws.com/human-pangenomics/pangenomes/freeze/freeze1/minigraph/CHM13v11Y.fa.gz
gunzip CHM13v11Y.fa.gz
gunzip chm13_cactus_filtered_ids.vcf.gz
gunzip chm13_cactus_filtered_ids_biallelic.vcf.gz

