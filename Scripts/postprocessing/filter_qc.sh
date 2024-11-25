#Use this script to filter out low quality variants

#!/bin/bash -l

#SBATCH --job-name=filter_qc
#SBATCH --account=pawsey0933
#SBATCH --partition=work
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --nodes=1
#SBATCH --time=1:00:00
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

#Filter based on qc 
bcftools view -v snps,indels sorted_toref_genmod_final_hprc_gnomad_1000g.vcf | bcftools filter -e 'ID~"^SV" || ID~"^Manta"' | bcftools view -i 'FILTER="PASS" && QUAL > 10' -o sorted_toref_genmod_final_snps_qc.vcf.gz
bcftools view -v other,indels sorted_toref_genmod_final_hprc_gnomad_1000g.vcf | bcftools filter -e 'ID~"^chr"' | bcftools view -i 'FILTER="PASS" && QUAL > 250' -o sorted_toref_genmod_final_manta_qc.vcf.gz
bcftools view -v other,indels sorted_toref_genmod_final_hprc_gnomad_1000g.vcf | bcftools filter -e 'ID~"^chr" || ID~"^Manta"' | bcftools view -i 'FILTER="PASS" && QUAL > 10' -o sorted_toref_genmod_final_tiddit_qc.vcf.gz

#tabix
tabix -p vcf sorted_toref_genmod_final_snps_qc.vcf.gz 
tabix -p vcf sorted_toref_genmod_final_manta_qc.vcf.gz 
tabix -p vcf sorted_toref_genmod_final_tiddit_qc.vcf.gz

#concatenate files back
bcftools concat -a sorted_toref_genmod_final_snps_qc.vcf.gz sorted_toref_genmod_final_manta_qc.vcf.gz sorted_toref_genmod_final_tiddit_qc.vcf.gz -Oz -o sorted_toref_genmod_final_qc.vcf.gz

#Index the filtered VCF
tabix -p vcf sorted_toref_genmod_final_qc.vcf.gz
