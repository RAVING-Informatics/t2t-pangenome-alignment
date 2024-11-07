#!/bin/bash

cd /path/to/pangenie.vcfs

for vcf in *genotyping_biallelic.vcf; do
    bgzip $vcf
    tabix -p vcf ${vcf}.gz
done
