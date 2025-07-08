## bedtools
# version 2.31.1


## input
# $1: work_dir, such as 'data/Exemplar/result/snippy/Bifidobacterium_longum'
# $2: ref_file, such as 'Bifidobacterium_longum.fna'
# $3: sliding window, such as 2000
## output file
# size.genome & windows.gc.txt


cd $1

faidx $2 -i chromsizes > size.genome
bedtools makewindows -g size.genome -w $3 > windows.bed
bedtools nuc -fi $2 -bed windows.bed |cut -f 1-3,5 > windows.gc.txt
