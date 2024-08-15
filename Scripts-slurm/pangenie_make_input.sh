#!/bin/bash

# Make and tidy inputs directory 
mkdir ./Inputs
input_file=./Inputs/pangenie.inputs
rm -f $input_file

# Prepare output directory 
outdir=/scratch/pawsey0933/cfolland/pangenie/output
mkdir $outdir

# Set config as supplied argument
config=$1

# Ensure config variable is set and file exists
if [ -z "${config}" ] || [ ! -f "${config}" ]; then
    echo "Error: config variable not set or ${config} not found"
    exit 1
fi

# Use an associative array to match sample name with correct metadata
declare -A inputs

# Sample and fq counter for summary
total_samples=0
total_pairs=0

# Loop through config, avoid whole pipe consumption/mix up with -u 3
while IFS=, read -r -u 3 sample fq1 fq2 platform library centre || [[ -n "$sample" ]]; do
    if [[ $sample =~ ^# ]]; then
        continue
    fi

    # Validate: Check if files exist
    if [ ! -f "$fq1" ] || [ ! -f "$fq2" ]; then
        echo "Error: One or both fastq files for sample $sample do not exist."
        exit 1
    fi

    # Count total pairs
    total_pairs=$((total_pairs+1))

    # Validate: Check if sample name corresponds to expected Fastq pattern (R1 and R2)
    if ! [[ "$fq1" =~ _R1\.fastq\.gz$ ]] || ! [[ "$fq2" =~ _R2\.fastq\.gz$ ]]; then
        echo "Error: fastq files for sample $sample do not match expected R1 and R2 pattern."
        exit 1
    fi

    # Extract the flowcell and lane info from the FASTQ header
    flowcell=$(zcat ${fq1} 2>/dev/null | head -1 | cut -d ':' -f 3)
    lane=$(zcat ${fq1} 2>/dev/null | head -1 | cut -d ':' -f 4)

    # Validate: Ensure flowcell and lane extracted align with expected format
    if [[ -z "$flowcell" ]] || [[ -z "$lane" ]]; then
        echo "Error: Unable to extract flowcell or lane information from fastq header for sample $sample."
        exit 1
    fi

    # Construct the input string and read group header for the current pair
    input_string="${fq1} ${fq2}"

    # Append to the associative array/dictionary
    if [ -z "${inputs[$sample]}" ]; then
        inputs[$sample]="$input_string"
    else
        inputs[$sample]="${inputs[$sample]} $input_string"
    fi

    # Print summary for cohort.config
    echo "Processed fastq files for sample $sample:"
    echo "R1: $fq1"
    echo "R2: $fq2"
    echo "Flowcell: $flowcell"
    echo "Lane: $lane"
    echo "Input string: $input_string"
    echo "------------------------------------------"

done 3< "$config" 

# Write the associative array to the run_parallel input file
for sample in "${!inputs[@]}"; do
    echo "${sample},\"${inputs[$sample]}\"" >> $input_file
done
