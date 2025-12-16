#!/bin/sh
set -eu

input_dir="/scratch/pawsey0933/cfolland/t2t/input_batch2"
sex="NA"
status="0"
lane="1"
batchID="bam2fastq_batch2"
out="samplesheet_${batchID}.csv"

[ -d "$input_dir" ] || { echo "ERROR: input_dir not found: $input_dir" >&2; exit 1; }

echo "patient,sex,status,sample,lane,fastq_1,fastq_2" > "$out"

missing_r2=0

# Iterate R1s deterministically
find "$input_dir" -type f -name "*_1*.fastq.gz" -print | sort | while IFS= read -r r1; do
  base=$(basename "$r1")
  sample=${base%%_*}

  # Try straightforward partner
  r2=$(printf %s "$r1" | sed 's/_1\.merged\.fastq\.gz$/_2.merged.fastq.gz/')
  if [ ! -f "$r2" ]; then
    # Fallback search
    r2=$(find "$input_dir" -type f -name "${sample}_2*.fastq.gz" -print | sort | head -n1 || true)
    if [ -z "${r2:-}" ]; then
      echo "WARN: No R2 for sample ${sample}; R1: ${r1}" >&2
      missing_r2=$((missing_r2+1))
      continue
    fi
  fi

  printf "%s,%s,%s,%s,%s,%s,%s\n" \
    "$sample" "$sex" "$status" "$sample" "$lane" "$r1" "$r2" >> "$out"
done

[ "$missing_r2" -gt 0 ] && echo "Completed with ${missing_r2} sample(s) missing R2." >&2
echo "Wrote: $out"
