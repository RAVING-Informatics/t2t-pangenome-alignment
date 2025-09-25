#!/bin/bash

# Script to generate a samplesheet for nf-core rnaseq pipeline from CRAM files
# Usage: ./generate_samplesheet.sh

set -euo pipefail  # Exit on error, undefined vars, pipe failures

# Define variables
input_dir="/scratch/pawsey0933/cfolland/t2t_input_cram/"  # Full path to input CRAM directory
file_type="cram"  # File type identifier
batch_id="batch2"  # Batch identifier for naming convention
output_file="samplesheet_${batch_id}.csv"

# Validate input directory exists
if [[ ! -d "$input_dir" ]]; then
    echo "Error: Input directory '$input_dir' does not exist!" >&2
    exit 1
fi

echo "Generating samplesheet from CRAM files in: $input_dir"

# Function to extract sample ID from filename
extract_sample_id() {
    local filename="$1"
    # Remove path, then extract everything before first underscore or dot
    basename "$filename" | sed 's/\([^_]*\).*/\1/' | sed 's/\.cram$//'
}

# Create temporary directory for intermediate files
temp_dir=$(mktemp -d)
trap "rm -rf $temp_dir" EXIT

# Find all CRAM files and extract sample information
declare -A samples
while IFS= read -r -d '' cram_file; do
    sample_id=$(extract_sample_id "$cram_file")
    
    # Look for .crai file in two possible formats:
    # 1. sampleid.cram.crai (standard format)
    # 2. sampleid.crai (alternative format)
    crai_file_standard="${cram_file}.crai"
    crai_file_alt="${cram_file%%.cram}.crai"
    
    if [[ -f "$crai_file_standard" ]]; then
        samples["$sample_id"]="$cram_file,$crai_file_standard"
        echo "Found sample: $sample_id (using ${crai_file_standard##*/})"
    elif [[ -f "$crai_file_alt" ]]; then
        samples["$sample_id"]="$cram_file,$crai_file_alt"
        echo "Found sample: $sample_id (using ${crai_file_alt##*/})"
    else
        echo "Warning: No .crai index found for $cram_file (checked both ${crai_file_standard##*/} and ${crai_file_alt##*/})" >&2
    fi
done < <(find "$input_dir" -name "*.cram" -type f -print0)


# Check if any samples were found
if [[ ${#samples[@]} -eq 0 ]]; then
    echo "Error: No CRAM files found in $input_dir" >&2
    exit 1
fi

# Generate samplesheet
echo "sample_id,mapped,index,file_type" > "$output_file"

# Sort sample IDs and write to samplesheet
for sample_id in $(printf '%s\n' "${!samples[@]}" | sort); do
    IFS=',' read -r cram_file crai_file <<< "${samples[$sample_id]}"
    echo "$sample_id,$cram_file,$crai_file,cram" >> "$output_file"
done

echo "Samplesheet generated: $output_file"
echo "Total samples: ${#samples[@]}"

# Display first few lines for verification
echo -e "\nFirst few lines of samplesheet:"
head -5 "$output_file"

# Validate the samplesheet format
echo -e "\nValidating samplesheet..."
if [[ $(head -1 "$output_file") == "sample,cram,crai,file_type" ]]; then
    echo "✓ Header format correct"
else
    echo "✗ Header format incorrect" >&2
    exit 1
fi

# Check for duplicate samples
duplicates=$(tail -n +2 "$output_file" | cut -d',' -f1 | sort | uniq -d)
if [[ -n "$duplicates" ]]; then
    echo "✗ Duplicate sample IDs found:" >&2
    echo "$duplicates" >&2
    exit 1
else
    echo "✓ No duplicate sample IDs"
fi

echo "✓ Samplesheet validation complete!"
