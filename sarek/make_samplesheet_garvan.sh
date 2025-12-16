#!/usr/bin/env bash
set -euo pipefail

# ---- user inputs ----
INPUT_DIR="/scratch/pawsey0933/cfolland/t2t_fastq"                 # directory containing FASTQs
MAP_TSV="/scratch/pawsey0933/cfolland/t2t_fastq/samples.txt"   # two columns: patient_id<TAB>sample_id (with header)
SEX="NA"                               # strandedness value you want in the 'sex' column
STATUS="0"
BATCH_ID="batch_mapped"
OUT="samplesheet_${BATCH_ID}.csv"

# ---- checks ----
[[ -d "$INPUT_DIR" ]] || { echo "ERROR: INPUT_DIR not found: $INPUT_DIR" >&2; exit 1; }
[[ -f "$MAP_TSV"   ]] || { echo "ERROR: MAP_TSV not found: $MAP_TSV" >&2; exit 1; }

# ---- load mapping: sample_id -> patient_id ----
declare -A PID_FOR
while IFS=$'\t' read -r patient_id sample_id; do
  # skip header/empties
  [[ -z "${patient_id:-}" || -z "${sample_id:-}" ]] && continue
  [[ "$patient_id" == "patient_id" && "$sample_id" == "sample_id" ]] && continue
  PID_FOR["$sample_id"]="$patient_id"
done < "$MAP_TSV"

# ---- header ----
echo "patient,sex,status,sample,lane,fastq_1,fastq_2" > "$OUT"

missing_r2=0
missing_map=0

# Find R1 files (handles both *_R1.fastq.gz and *_1.fastq.gz), sorted
while IFS= read -r r1; do
  base="$(basename "$r1")"
  # lane = token after the first underscore
  # e.g. HTCWCDSXC_1_241218_FS11403233_... -> lane=1
  lane="$(printf '%s' "$base" | awk -F'_' '{print $2}')"

  # sample_id = token matching FS[0-9]+
  sample="$(printf '%s' "$base" | awk -F'_' '{for(i=1;i<=NF;i++) if ($i ~ /^FS[0-9]+$/) {print $i; exit}}')"
  if [[ -z "${sample:-}" ]]; then
    # fallback: many files have sample as 4th token
    sample="$(printf '%s' "$base" | awk -F'_' 'NF>=4{print $4}')"
  fi

  # get patient_id via map (warn if missing, but still proceed using sample as patient)
  patient="${PID_FOR[$sample]-$sample}"
  if [[ "$patient" == "$sample" ]]; then
    echo "WARN: No patient_id mapping for sample_id=$sample (file: $base). Using sample as patient." >&2
    ((missing_map++)) || true
  fi

  # Derive matching R2
  if [[ "$r1" =~ _R1\.fastq\.gz$ ]]; then
    r2="${r1/_R1.fastq.gz/_R2.fastq.gz}"
  elif [[ "$r1" =~ _1\.fastq\.gz$ ]]; then
    r2="${r1/_1.fastq.gz/_2.fastq.gz}"
  else
    # last-resort search
    r2="$(find "$INPUT_DIR" -type f -name "*${sample}*_R2.fastq.gz" -o -name "*${sample}*_2.fastq.gz" -print | sort | head -n1 || true)"
  fi

  if [[ ! -f "${r2:-/dev/null}" ]]; then
    echo "WARN: Could not find R2 for R1: $r1" >&2
    ((missing_r2++)) || true
    continue
  fi

  printf "%s,%s,%s,%s,%s,%s,%s\n" \
    "$patient" "$SEX" "$STATUS" "$sample" "$lane" "$r1" "$r2" >> "$OUT"

done < <(
  find "$INPUT_DIR" -type f \( -name "*_R1.fastq.gz" -o -name "*_1.fastq.gz" \) -print | sort
)

echo "Wrote: $OUT"
(( missing_r2 > 0 ))  && echo "Note: ${missing_r2} R1 files had no matching R2." >&2
(( missing_map > 0 )) && echo "Note: ${missing_map} samples missing in map; used sample_id as patient." >&2
