## humann_barplot
# humann version 3.7


## input
# $1: work_dir, such as 'data/Exemplar'
# $2: pathway, such as 'GLYCOCAT-PWY'
## output
# result/humann3/barplot_${path}.png/pdf


cd $1

humann_barplot \
   --input result/humann3/pathabundance_relab.pcl --focal-feature $2 \
   --focal-metadata Group --last-metadata Group \
   --output result/humann3/png/barplot_$2.png --sort sum metadata 
# humann_barplot \
#    --input result/humann3/pathabundance_relab.tsv --focal-feature $2 \
#    --output result/humann3/png/barplot_$2.png --sort sum