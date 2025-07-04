#!/bin/bash
BASE_DIR=/scratch/pawsey0933/T2T/hg38_realignment/sarek_bwamem2_run2/preprocessing/mapped/

for SAMPLE_DIR in "$BASE_DIR"/*; do
    SAMPLE=$(basename "$SAMPLE_DIR")
    CRAM_FILE="${SAMPLE}.sorted.cram"
    FULL_PATH="${SAMPLE_DIR}/${CRAM_FILE}"

    if [[ -f "$FULL_PATH" ]]; then
        echo "Submitting job for $FULL_PATH"
        sbatch samtools_stats.sh "$CRAM_FILE"
    else
        echo "❌ CRAM file not found: $FULL_PATH"
    fi
done
