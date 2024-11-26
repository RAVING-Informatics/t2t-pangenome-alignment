import pandas as pd
import argparse

def parse_vcf(input_vcf, output_file, output_format='tsv'):
    # VEP headers as provided
    vep_headers = [
        "Allele", "Consequence", "IMPACT", "SYMBOL", "Gene", "Feature_type", "Feature", "BIOTYPE",
        "EXON", "INTRON", "HGVSc", "HGVSp", "cDNA_position", "CDS_position", "Protein_position",
        "Amino_acids", "Codons", "Existing_variation", "DISTANCE", "STRAND", "FLAGS", "VARIANT_CLASS",
        "SYMBOL_SOURCE", "HGNC_ID", "CANONICAL", "MANE_SELECT", "MANE_PLUS_CLINICAL", "TSL", "APPRIS",
        "CCDS", "ENSP", "SWISSPROT", "TREMBL", "UNIPARC", "UNIPROT_ISOFORM", "SOURCE", "GENE_PHENO",
        "DOMAINS", "miRNA", "HGVS_OFFSET", "AF", "AFR_AF", "AMR_AF", "EAS_AF", "EUR_AF", "SAS_AF",
        "gnomADe_AF", "gnomADe_AFR_AF", "gnomADe_AMR_AF", "gnomADe_ASJ_AF", "gnomADe_EAS_AF",
        "gnomADe_FIN_AF", "gnomADe_NFE_AF", "gnomADe_OTH_AF", "gnomADe_SAS_AF", "gnomADg_AF",
        "gnomADg_AFR_AF", "gnomADg_AMI_AF", "gnomADg_AMR_AF", "gnomADg_ASJ_AF", "gnomADg_EAS_AF",
        "gnomADg_FIN_AF", "gnomADg_MID_AF", "gnomADg_NFE_AF", "gnomADg_OTH_AF", "gnomADg_SAS_AF",
        "MAX_AF", "MAX_AF_POPS", "FREQS", "CLIN_SIG", "SOMATIC", "PHENO", "PUBMED", "MOTIF_NAME",
        "MOTIF_POS", "HIGH_INF_POS", "MOTIF_SCORE_CHANGE", "TRANSCRIPTION_FACTORS", "clinvar",
        "clinvar_CLNSIG", "clinvar_CLNREVSTAT", "clinvar_CLNDN"
    ]
    
    # Open the VCF file and process
    with open(input_vcf, 'r') as f:
        lines = f.readlines()
    
    # Filter out metadata lines
    vcf_data = [line.strip() for line in lines if not line.startswith('#')]
    
    # Initialize a list for parsed rows
    parsed_rows = []
    
    for row in vcf_data:
        fields = row.split('\t')
        chrom, pos, v_id, ref, alt, qual, filt, info = fields[:8]
        
        # Parse INFO field
        info_dict = {key.split('=')[0]: key.split('=', 1)[1] for key in info.split(';') if '=' in key}
        csq_data = info_dict.get('CSQ', '').split(',')
        genetic_models = info_dict.get('GeneticModels', '')  # Preserve full GeneticModels field
        
        # Expand CSQ entries
        for csq_entry in csq_data:
            csq_fields = csq_entry.split('|')
            csq_dict = dict(zip(vep_headers, csq_fields))
            
            # Add fixed fields to the row
            csq_dict['CHROM'] = chrom
            csq_dict['POS'] = pos
            csq_dict['ID'] = v_id
            csq_dict['REF'] = ref
            csq_dict['ALT'] = alt
            csq_dict['QUAL'] = qual
            csq_dict['FILTER'] = filt
            
            # Add GeneticModels as a single intact field
            csq_dict['GeneticModels'] = genetic_models
            
            parsed_rows.append(csq_dict)
    
    # Convert to DataFrame
    df = pd.DataFrame(parsed_rows)
    
    # Reorder columns to start with the required fields
    required_columns = ['CHROM', 'POS', 'ID', 'REF', 'ALT', 'QUAL', 'FILTER', 'GeneticModels']
    all_columns = required_columns + [col for col in df.columns if col not in required_columns]
    df = df[all_columns]
    
    # Write to file
    if output_format == 'tsv':
        df.to_csv(output_file, sep='\t', index=False)
    else:
        df.to_csv(output_file, index=False)

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="Parse a VCF file and extract INFO fields.")
    parser.add_argument("input_vcf", help="Input VCF file")
    parser.add_argument("output_file", help="Output file (TSV or CSV)")
    parser.add_argument("--output_format", choices=['tsv', 'csv'], default='tsv', help="Output file format (default: TSV)")
    args = parser.parse_args()
    
    parse_vcf(args.input_vcf, args.output_file, output_format=args.output_format)
