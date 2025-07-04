**Samtools stats**

Run `samtools stats` on the mapped `BAM` files output from `vg_snakemake`.
Use the use the `samtools_submit.sh` script to specify the location of the `BAM` files. This script will iterate through and submit individual jobs for each in combination with `samtools_stats.sh`.
