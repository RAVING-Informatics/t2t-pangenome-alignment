#source the chain file
wget https://hgdownload.soe.ucsc.edu/gbdb/hg38/liftOver/hg38ToGCA_009914755.4.over.chain.gz
gunzip hg38ToGCA_009914755.4.over.chain.gz

#define $ChainDir
export ChainDir=/path/to/chain_file

#perform liftover - benign 
cd $ANNOTSV/share/AnnotSV/Annotations_Human/SVincludedInFt/BenignSV/CHM13/
for f in ../GRCh38/benign*_GRCh38.sorted.bed
do
	tmpGRCh38file=`basename $f`
	grep -v "PC:" $f > $tmpGRCh38file
	CHM13file=`echo $tmpGRCh38file | sed "s/GRCh38/CHM13/"`
	echo "$tmpGRCh38file => $CHM13file"
	$ANNOTSV/share/tcl/AnnotSV/Scripts/lift_Over_a_BED_file.tcl $tmpGRCh38file \
	$CHM13file $ChainDir/hg38ToGCA_009914755.4.over.chain
	rm $tmpGRCh38file
done

#perform liftover - pathogenic
cd $ANNOTSV/share/AnnotSV/Annotations_Human/FtIncludedInSV/PathogenicSV/CHM13/
for f in ../GRCh38/pathogenic_*_SV_GRCh38.sorted.bed 
do
	tmpGRCh38file=`basename $f`
	grep -v "PC:" $f > $tmpGRCh38file
	CHM13file=`echo $tmpGRCh38file | sed "s/GRCh38/CHM13/"`
	echo "$tmpGRCh38file => $CHM13file"
	$ANNOTSV/share/tcl/AnnotSV/Scripts/lift_Over_a_BED_file.tcl $tmpGRCh38file \
	$CHM13file $ChainDir/hg38ToGCA_009914755.4.over.chain
	rm $tmpGRCh38file
done

#liftover - clinvar
cd $ANNOTSV/share/AnnotSV/Annotations_Human/FtIncludedInSV/PathogenicSNVindel/CHM13/
f=../GRCh38/pathogenic_SNVindel_GRCh38.sorted.bed
tmpGRCh38file=`basename $f`
grep -v "PC:" $f > $tmpGRCh38file
CHM13file=`echo $tmpGRCh38file | sed "s/GRCh38/CHM13/"`
echo "$tmpGRCh38file => $CHM13file"
$ANNOTSV/share/tcl/AnnotSV/Scripts/lift_Over_a_BED_file.tcl $tmpGRCh38file \
$CHM13file $ChainDir/hg38ToGCA_009914755.4.over.chain
rm $tmpGRCh38file
