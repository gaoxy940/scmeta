#!/bin/bash
# chmod u=rwx script.sh

# Check fastq.gz file integrity

# input
# $1: work_dir, such as 'data/Exemplar'
# output: temp/fastqc/ result/error_samples_list.txt

cd $1

# run fastqc
mkdir -p temp/fastqc
fastqc -t 5 -o temp/fastqc seq/*.gz > temp/fastqc/fastqc_out.log 2>&1

touch temp.tmp
grep "Failed to process file" temp/fastqc/fastqc_out.log > temp.tmp
touch result/error_samples_list.txt
if [ -s temp.tmp ]; then
    (cat temp.tmp | awk '{print $NF}' | awk -F'_' '{print $1}' | sort | uniq) > result/error_samples_list.txt
    cat result/error_samples_list.txt | while read prefix; do find seq -name "${prefix}*" -exec rm -f {} +; done
fi

rm temp.tmp
cp temp/fastqc/fastqc_out.log result/log.fastqc.txt