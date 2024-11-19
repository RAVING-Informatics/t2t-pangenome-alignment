#!/bin/bash -l

#SBATCH --job-name=filter_vcfs
#SBATCH --account=pawsey0933
#SBATCH --partition=work
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --nodes=1
#SBATCH --time=6:00:00
#SBATCH --mail-user=chiara.folland@perkins.org.au
#SBATCH --mail-type=END
#SBATCH --error=%j.%x.err
#SBATCH --output=%j.%x.out
#SBATCH --export=ALL

#load modules
module load vcftools/0.1.16--pl5321hd03093a_7
module load bcftools/1.15--haf5b3da_0
conda activate vcf_tools

cd /scratch/pawsey0933/cfolland/t2t/

#Filter based on allele frequency using bcftools
bcftools filter -i '((INFO/AC <= 5) && (INFO/AF_HPRC <= 0.001 || INFO/AF_HPRC = ".") && (INFO/AF_1000G <= 0.001 || INFO/AF_1000G = ".") && (INFO/AF_gnomad <= 0.001 || INFO/AF_gnomad = "."))' \
    sorted_toref_genmod_final_hprc_gnomad_1000g.vcf.gz -o sorted_toref_genmod_filtered.vcf.gz

#Index the filtered VCF
tabix -p vcf sorted_toref_genmod_filtered.vcf.gz 
