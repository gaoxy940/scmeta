## FastTree
# version 2.1.11

## input
# $1: work_dir, such as 'data/Exemplar/result/snippy/species_name'
## output
# tree.nwk

cd $1

snippy-clean_full_aln core-snps.aln > core-snps.clean.aln
FastTree -nt -gtr core-snps.clean.aln > tree.nwk
