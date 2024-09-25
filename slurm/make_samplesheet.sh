#!/bin/bash

# Directory containing FASTQ files
FASTQ_DIR="/scratch/pawsey0933/T2T/fastq_3/reads"

# Output samplesheet
SAMPLESHEET="t2t_samplesheet.csv"

# Loop over R1 files and find corresponding R2 files
for fq1 in $FASTQ_DIR/*_1.merged.fastq.gz; do
    # Extract the sample ID from the filename
    sample_id=$(basename $fq1 | cut -d '_' -f 1)
    
    # Construct the R2 filename
    fq2="${fq1/_1.merged.fastq.gz/_2.merged.fastq.gz}"
    
    # Write the sample information to the samplesheet
    echo "$sample_id,$fq1,$fq2,illumina,1,KCCG" >> $SAMPLESHEET
done

echo "Samplesheet generated: $SAMPLESHEET"
