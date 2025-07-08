## humann3
# version 3.7
# metaphlan version 4.1.1 (11 Mar 2024)
# metaphlan database index mpa_vOct22_CHOCOPhlAnSGB_202403

## input
# $1: work_dir, such as 'data/Exemplar'

cd $1

## run humann3
mkdir -p temp/humann3
awk 'NR>1' group_filtered.txt | cut -f1 | rush -j 5 \
      "humann --input-format fastq.gz --input temp/fastp/{1}_1.fastq.gz  \
      --output temp/humann3 --threads 10 \
      --metaphlan-options '--bowtie2db /app/scmeta/database/metaphlan4 -x mpa_vOct22_CHOCOPhlAnSGB_202403 --nproc 10 --offline' \
      --search-mode uniref90"

for i in $(awk 'NR>1' group_filtered.txt | cut -f1); do  
   mv temp/humann3/${i}_1_humann_temp/${i}_1_metaphlan_bugs_list.tsv temp/humann3/${i}_metaphlan_bugs_list.tsv
   mv temp/humann3/${i}_1_genefamilies.tsv temp/humann3/${i}_genefamilies.tsv
   humann_regroup_table \
   -i temp/humann3/${i}_genefamilies.tsv \
   -g uniref90_ko \
   -o temp/humann3/${i}_ko.tsv
done

/bin/rm -rf temp/humann3/*_humann_temp

## results merge
mkdir -p result/humann3

# species composition table
merge_metaphlan_tables.py temp/humann3/*_metaphlan_bugs_list.tsv | \
   sed 's/_metaphlan_bugs_list//g' | tail -n+2 | sed '1 s/clade_name/ID/'> result/humann3/metaphlan4_taxonomy.tsv
csvtk -t stat result/humann3/metaphlan4_taxonomy.tsv

# function composition table
humann_join_tables --input temp/humann3 \
--file_name pathabundance \
--output result/humann3/pathabundance.tsv
sed -i '1s/# //g; 1s/_1_Abundance//g' result/humann3/pathabundance.tsv

humann_join_tables --input temp/humann3/ \
--file_name ko \
--output result/humann3/ko.tsv
sed -i '1s/_1_Abundance-RPKs//g' result/humann3/ko.tsv

# normalization
humann_renorm_table \
--input result/humann3/pathabundance.tsv \
--units relab \
--output result/humann3/pathabundance_relab.tsv

humann_renorm_table \
--input result/humann3/ko.tsv \
--units relab \
--output result/humann3/ko_relab.tsv

# split_stratified_table
# pathabundance_relab_unstratified.tsv: (functional component)
# pathabundance_relab_stratified.tsv: (the contribution of each bacterium to this function pathway)
humann_split_stratified_table \
--input result/humann3/pathabundance_relab.tsv \
--output result/humann3/

humann_split_stratified_table \
--input result/humann3/ko_relab.tsv \
--output result/humann3/ 


# Kegg comments on the KO matrix
/app/scmeta/script/summarizeAbundance.py \
-i result/humann3/ko_relab_unstratified.tsv \
-m /app/scmeta/database/kegg/KO1-4.txt \
-c 2,3,4 -s ',+,+,' -n raw \
-o result/humann3/KEGG

sed -i '/^[ ]\+/d' result/humann3/KEGG.PathwayL2.raw.txt


# add grouping information
#head -n1 result/humann3/pathabundance_relab.tsv | sed 's/Pathway/Sample/' | tr '\t' '\n' > temp/header
#awk 'BEGIN{FS=OFS="\t"}NR==FNR{a[$1]=$2}NR>FNR{print a[$1]}' group_filtered.txt temp/header | tr '\n' '\t'|sed 's/\t$/\n/' > temp/group
cat group_filtered.txt | cut -f2 | perl -pe 's/\n/\t/g' | perl -pe s'/\t$/\n/' > temp/group
cat <(head -n1 result/humann3/pathabundance_relab.tsv) temp/group <(tail -n+2 result/humann3/pathabundance_relab.tsv) \
> result/humann3/pathabundance_relab.pcl
#rm -f temp/header temp/group
rm -f temp/group
