from Bio import SeqIO
from Bio.Seq import Seq
from Bio.Data import CodonTable
import os,sys

def is_four_fold_degenerate(codon, position, codon_table):
    if "-" in codon or "N" in codon:
        return False
    original_aa = codon_table.forward_table.get(codon, None)
    if original_aa is None:
        return False
    nucleotides = "ACGT"
    consistent_aa = set()
    for nt in nucleotides:
        modified_codon = list(codon)
        modified_codon[position] = nt
        modified_codon = "".join(modified_codon)
        aa = codon_table.forward_table.get(modified_codon, None)
        if aa is not None:
            consistent_aa.add(aa)
    
    return len(consistent_aa) == 1

def extract_four_fold_degenerate_sites(input_fasta, output_fasta):
    codon_table = CodonTable.unambiguous_dna_by_id[1]  # Standard codon table
    records = list(SeqIO.parse(input_fasta, "fasta"))
    alignment_length = len(records[0].seq)
    if alignment_length % 3 != 0:
        raise ValueError("Alignment length must be a multiple of 3 for codon-based analysis.")
    
    four_fold_sites = {record.id: [] for record in records}
    
    for i in range(0, alignment_length, 3):  # Iterate over codons
        for pos in range(3):  # Within each codon, check each position
            is_degenerate = True
            codons = [str(record.seq[i:i+3]) for record in records]
            for codon in codons:
                if not is_four_fold_degenerate(codon, pos, codon_table):
                    is_degenerate = False
                    break
            if is_degenerate:
                for record in records:
                    four_fold_sites[record.id].append(record.seq[i + pos])
     with open(output_fasta, "w") as output_handle:
        for record in records:
            degenerate_seq = "".join(four_fold_sites[record.id])
            output_handle.write(f">{record.id}\n{degenerate_seq}\n")

# Usage
input_fasta,output_fasta = sys.argv[1:3] #"input_alignment.fasta"  
extract_four_fold_degenerate_sites(input_fasta, output_fasta)

