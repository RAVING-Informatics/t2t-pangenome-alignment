# SV Annotation

## AnnotSV 
- As of Jul 2025, AnnotSV supports T2T-CHM13-based VCFs.
- To use AnnotSV with CHM13-based VCFs, ensure the version is >3.5.
- Once AnnotSV is installed as per the [documentation](https://github.com/lgmgeo/AnnotSV/blob/master/share/doc/AnnotSV/quickstart.md), the CHM13-based benign BED annotations need to be prepared via liftover. See the script `liftover_annotsv_chm13.sh`.

**Issues with AnnotSV**
- Does not appear to match SVs based on SVTYPE (i.e. INS, DEL, INV). Only matches based on co-ordinate overlaps.
- Cannot get AnnotSV to output to VCF (issue with python incompatibility).

## SVAFotate
- Tool designed to annotate SVs with population level AFs and other related metrics.
- Allows for matching with SVTYPE.
- Outputs naturally to VCF.
- Does not currently support CHM13
- Highly customisable


