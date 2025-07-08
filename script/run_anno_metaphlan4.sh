## metaphlan4
#  version 4.1.1 (11 Mar 2024)
# --index mpa_vOct22_CHOCOPhlAnSGB_202403

## input
# $1: work_dir, such as 'data/Exemplar'

cd $1

# run metaphlan4
mkdir -p temp/metaphlan4
mkdir -p result/metaphlan4
db=/app/scmeta/database/metaphlan4

awk 'NR>1' group_filtered.txt | cut -f1 | rush -j 5 \
      "metaphlan temp/fastp/{1}_1.fastq.gz --input_type fastq \
        -o temp/metaphlan4/{1}.txt \
        --bowtie2db $db \
        --bowtie2out temp/metaphlan4/{1}.bz2 \
        -x mpa_vOct22_CHOCOPhlAnSGB_202403 \
        --nproc 10"

merge_metaphlan_tables.py temp/metaphlan4/*.txt > result/metaphlan4/merged_abundance_table.txt


cd result/metaphlan4
# select row.sum > 10
head -2 merged_abundance_table.txt > combined.percentages.up0
awk '{sum=0; for(i=2; i<=NF; i++) sum+=$i; if (sum > 10) print $0}' merged_abundance_table.txt >> combined.percentages.up0
## grep k/p/c/o/f/g/s
grep -E '(k__Bacteria.*p__.*c__.*o__.*f__.*g__.*s__)|(clade_name)' combined.percentages.up0 |grep -v 't__'|sed 's/\ \ /\ /g'|sed 's/\ /\t/g' > metaphlan4_combined.percentages.up0_all.txt
# k
grep -E '(k__.*)|(clade_name)' combined.percentages.up0 |grep -v 't__'|grep -v 'p__'|sed 's/^.*k__/k__/g'|sed 's/\ \ /\ /g'|sed 's/\ /\t/g' > metaphlan4_combined.percentages.up0_kingdom.txt
# p
grep -E '(p__.*)|(clade_name)' combined.percentages.up0 |grep -v 't__'|grep -v 'c__'|sed 's/^.*p__/p__/g'|sed 's/\ \ /\ /g'|sed 's/\ /\t/g' > metaphlan4_combined.percentages.up0_phylum.txt
# c
grep -E '(c__.*)|(clade_name)' combined.percentages.up0 |grep -v 't__'|grep -v 'o__'|sed 's/^.*c__/c__/g'|sed 's/\ \ /\ /g'|sed 's/\ /\t/g' > metaphlan4_combined.percentages.up0_class.txt
# o
grep -E '(o__.*)|(clade_name)' combined.percentages.up0 |grep -v 't__'|grep -v 'f__'|sed 's/^.*o__/o__/g'|sed 's/\ \ /\ /g'|sed 's/\ /\t/g' > metaphlan4_combined.percentages.up0_order.txt
# f
grep -E '(f__.*)|(clade_name)' combined.percentages.up0 |grep -v 't__'|grep -v 'g__'|sed 's/^.*f__/f__/g'|sed 's/\ \ /\ /g'|sed 's/\ /\t/g' > metaphlan4_combined.percentages.up0_family.txt
# g
grep -E '(g__.*)|(clade_name)' combined.percentages.up0 |grep -v 't__'|grep -v 's__'|sed 's/^.*g__/g__/g'|sed 's/\ \ /\ /g'|sed 's/\ /\t/g' > metaphlan4_combined.percentages.up0_genus.txt
# s
grep -E '(.*s__)|(clade_name)' combined.percentages.up0 |grep -v 't__'|sed 's/^.*s__/s__/g'|sed 's/\ \ /\ /g'|sed 's/\ /\t/g' > metaphlan4_combined.percentages.up0_species.txt
