#!/bin/bash -l

#SBATCH --job-name=bcftools_stats
#SBATCH --account=pawsey0933
#SBATCH --partition=work
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=24
#SBATCH --mem=16G
#SBATCH --nodes=1
#SBATCH --time=3:00:00
#SBATCH --mail-user=chiara.folland@perkins.org.au
#SBATCH --mail-type=END
#SBATCH --error=%j.%x.err
#SBATCH --output=%j.%x.out
#SBATCH --export=NONE

#load modules
module load bcftools/1.15--haf5b3da_0

#Define variables
REF=/software/projects/pawsey0933/sv/references/hg38_masked/Homo_sapiens_assembly38_masked.fasta
#/scratch/pawsey0933/pangenome/refs/chm13v2.0.maskedY.rCRS.EBV.fasta
INPUT_DIR=/scratch/pawsey0933/cfolland/benchmark/vcfs/deepvariant/linear/individual/hg38
#/scratch/pawsey0933/cfolland/benchmark/vcfs/dysgu/linear/hg38/
OUTPUT_DIR=/scratch/pawsey0933/cfolland/benchmark/output/linear/bcftools_stats/individual/

ls "$INPUT_DIR" | grep 'vcf' | grep -v 'tbi' | while read -r file; do

    basename=${file%%.*}
    OUTPUT="$OUTPUT_DIR/${basename}.hg38.deepvariant.bcftools_stats.txt"
    #OUTPUT="$OUTPUT_DIR/${basename}.hg38.dysgu.bcftools_stats.txt" 

    if [ -f "$OUTPUT" ]; then
        echo "✅ Output already exists for $file, skipping: $OUTPUT"
    else
        echo "📊 Calculating bcftools stats for $basename"
        VCF="${basename}.deepvariant.vcf.gz"
        #VCF="${basename}.sorted.cram_dysgu.vcf"
        bcftools stats "$INPUT_DIR/$VCF" > "$OUTPUT"
    fi

done
