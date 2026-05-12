#!/bin/bash -l

#SBATCH --job-name=bed_vcf
#SBATCH --account=pawsey0933
#SBATCH --partition=work
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=16G
#SBATCH --nodes=1
#SBATCH --time=03:00:00
#SBATCH --mail-user=chiara.folland@perkins.org.au
#SBATCH --mail-type=END
#SBATCH --error=%j.%x.err
#SBATCH --output=%j.%x.out
#SBATCH --export=ALL

module load bcftools/1.15--haf5b3da_0

annotate=/scratch/pawsey0933/cfolland/t2t/batch2/annotation/
ref=/software/projects/pawsey0933/pangenome/refs/chm13v2.0.maskedY.rCRS.EBV.fasta

cd $annotate

# PREPROCESSING 
# convert multiallelic to biallelic and sort vcf
bcftools norm -m -any --check-ref skip -f $ref -o $annotate/hprc-v2.0-mc-chm13.wave.biallelic.vcf.gz $annotate/hprc-v2.0-mc-chm13.wave.vcf.gz
bcftools sort -T $annotate -o $annotate/hprc-v2.0-mc-chm13.wave.biallelic.sorted.vcf.gz $annotate/hprc-v2.0-mc-chm13.wave.biallelic.vcf.gz
tabix -p vcf $annotate/hprc-v2.0-mc-chm13.wave.biallelic.sorted.vcf.gz

## CONVERT VCF TO BED
# NOTE, this script uses the following logic:
# CHROM → column 1. -> remove "chr" prefix
# POS → START (VCF POS is 1-based; BED is 0-based, so subtract 1 if you want strict BED)
# END → compute from POS + SVLEN (or from REF/ALT lengths if SVLEN not present)
# SVLEN → from INFO (LEN= or derived) (absolute value)
# SVTYPE → from INFO (TYPE= if present, otherwise infer)
# SOURCE → fixed label (e.g., your caller name) -> change "HPRCv2_wave" to fit the source of the VCF
# SV_ID → VCF ID column
# AF → from INFO (AF=)
# Other columns - added to be compatible with SVAFotate

INPUT=hprc-v2.0-mc-chm13.wave.biallelic.sorted.vcf.gz
OUTPUT=hprc-v2.0-mc-chm13.wave.biallelic.sorted.bed.gz
SOURCE="HPRCv2_wave"

LC_ALL=C zcat "$INPUT" | awk -v source="$SOURCE" '
BEGIN {
    OFS="\t";
    print header;

    n_header = split(header, h, "\t");
    fixed_cols = 8;
    extra_cols = n_header - fixed_cols;
}
!/^#/ {
    chrom=$1; pos=$2; id=$3; ref=$4; alt=$5; info=$8;

    # added normalisation here
    sub(/^chr/, "", chrom)
    if (chrom == "M") chrom = "MT"

    start = pos - 1;

    svlen=""; svtype=""; af="";
    n = split(info, fields, ";");

    for (i=1; i<=n; i++) {
        if (fields[i] ~ /^LEN=/)  { split(fields[i], a, "="); svlen=a[2]; }
        if (fields[i] ~ /^TYPE=/) { split(fields[i], a, "="); svtype=a[2]; }
        if (fields[i] ~ /^AF=/)   { split(fields[i], a, "="); af=a[2]; }
    }

    if (svlen == "") svlen = length(alt) - length(ref);
    if (svlen < 0) svlen = -svlen;

    end = start + svlen;

    if (svtype == "") {
        if (length(alt) > length(ref)) svtype="INS";
        else if (length(alt) < length(ref)) svtype="DEL";
        else svtype="MNP";
    }

    printf "%s\t%d\t%d\t%d\t%s\t%s\t%s\t%s",
        chrom, start, end, svlen, svtype, source, id, af;

    for (i=1; i<=extra_cols; i++) printf "\tNA";
    printf "\n";
}
' | gzip > "$OUTPUT"
