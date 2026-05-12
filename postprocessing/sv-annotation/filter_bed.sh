#!/bin/bash -l

#SBATCH --nodes=1
#SBATCH -c 4                          
#SBATCH --job-name=filter_bed
#SBATCH --partition=work
#SBATCH --account=pawsey0933
#SBATCH --mem=16G
#SBATCH --time=1:00:00
#SBATCH --mail-user=chiara.folland@perkins.org.au
#SBATCH --mail-type=END
#SBATCH --error=%j.%x.err
#SBATCH --output=%j.%x.out
#SBATCH --export=ALL

IN_BED=/scratch/pawsey0933/cfolland/t2t/batch2/annotation/hgsvc3-hprc-2024-02-23-mc-chm13-vcfbub.a100k.wave.norm.biallelic.sorted.fixed.bed.gz
OUT_BED=/scratch/pawsey0933/cfolland/t2t/batch2/annotation/hgsvc3-hprc-2024-02-23-mc-chm13-vcfbub.a100k.wave.norm.biallelic.sorted.len50.bed.gz

awk '
BEGIN { before=0; after=0; OFS="\t" }

NR==1 {
    print
    next
}

{
    before++

    if ($4 > 50) {
        print
        after++
    }
}

END {
    print "Total variants before filtering: " before > "/dev/stderr"
    print "Total variants after filtering: " after > "/dev/stderr"
}
' "$IN_BED" | gzip > "$OUT_BED"
