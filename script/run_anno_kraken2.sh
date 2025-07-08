## kraken2
# version 2.1.3
# --db pluspf16g

## input
# $1: work_dir, such as 'data/Exemplar'
# $2: kraken2.db
# pluspf16g(16GB) or pluspf(69GB) or pluspfp(144GB)

cd $1

# run kraken2
mkdir -p temp/kraken2
mkdir -p result/kraken2
db=/app/scmeta/database/kraken2

awk 'NR>1' group_filtered.txt | cut -f1 | rush -j 5 \
      "kraken2 --db ${db}/$2 \
      --gzip-compressed  \
      --paired temp/fastp/{1}_?.fastq.gz \
      --threads 10 --use-names --report-zero-counts \
      --report temp/kraken2/{1}.report \
      --output temp/kraken2/{1}.output && \
      sed -i 's/\s\s*2\s\s*Bacteria/\tD\t2\t    Bacteria/' temp/kraken2/{1}.report && \
      kreport2mpa.py -r temp/kraken2/{1}.report \
      --display-header --percentages -o temp/kraken2/{1}.percentages"

# combine mpa
combine_mpa.py -i `awk 'NR>1' group_filtered.txt|cut -f1|sed 's/^/temp\/kraken2\//;s/$/.percentages/'|tr '\n' ' '|sed 's/,$//'`  -o result/kraken2/kraken2.${2}_combined.percentages


cd result/kraken2
# select row.sum > 10
head -1 kraken2.${2}_combined.percentages | sed '1 s/.report//g' > kraken2.${2}_combined.percentages.up0
awk '{sum=0; for(i=2; i<=NF; i++) sum+=$i; if (sum > 10) print $0}' kraken2.${2}_combined.percentages >> kraken2.${2}_combined.percentages.up0
## grep k/p/c/o/f/g/s
grep -E '(k__Bacteria.*p__.*c__.*o__.*f__.*g__.*s__)|(Classification)' kraken2.${2}_combined.percentages.up0 |grep -v 't__'|sed 's/\ \ /\ /g'|sed 's/\ /\t/g' > kraken2.${2}_combined.percentages.up0_all.txt
# k
grep -E '(k__.*)|(Classification)' kraken2.${2}_combined.percentages.up0 |grep -v 't__'|grep -v 'p__'|sed 's/^.*k__/k__/g'|sed 's/\ \ /\ /g'|sed 's/\ /\t/g' > kraken2.${2}_combined.percentages.up0_kingdom.txt
# p
grep -E '(p__.*)|(Classification)' kraken2.${2}_combined.percentages.up0 |grep -v 't__'|grep -v 'c__'|sed 's/^.*p__/p__/g'|sed 's/\ \ /\ /g'|sed 's/\ /\t/g' > kraken2.${2}_combined.percentages.up0_phylum.txt
# c
grep -E '(c__.*)|(Classification)' kraken2.${2}_combined.percentages.up0 |grep -v 't__'|grep -v 'o__'|sed 's/^.*c__/c__/g'|sed 's/\ \ /\ /g'|sed 's/\ /\t/g' > kraken2.${2}_combined.percentages.up0_class.txt
# o
grep -E '(o__.*)|(Classification)' kraken2.${2}_combined.percentages.up0 |grep -v 't__'|grep -v 'f__'|sed 's/^.*o__/o__/g'|sed 's/\ \ /\ /g'|sed 's/\ /\t/g' > kraken2.${2}_combined.percentages.up0_order.txt
# f                       
grep -E '(f__.*)|(Classification)' kraken2.${2}_combined.percentages.up0 |grep -v 't__'|grep -v 'g__'|sed 's/^.*f__/f__/g'|sed 's/\ \ /\ /g'|sed 's/\ /\t/g' > kraken2.${2}_combined.percentages.up0_family.txt
# g                    
grep -E '(g__.*)|(Classification)' kraken2.${2}_combined.percentages.up0 |grep -v 't__'|grep -v 's__'|sed 's/^.*g__/g__/g'|sed 's/\ \ /\ /g'|sed 's/\ /\t/g' > kraken2.${2}_combined.percentages.up0_genus.txt                      
# s                     
grep -E '(.*s__)|(Classification)' kraken2.${2}_combined.percentages.up0 |grep -v 't__'|sed 's/^.*s__/s__/g'|sed 's/\ \ /\ /g'|sed 's/\ /\t/g' > kraken2.${2}_combined.percentages.up0_species.txt
