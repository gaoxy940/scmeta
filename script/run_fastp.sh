#!/bin/bash
# chmod u=rwx script.sh

# input
# $1: work_dir, such as 'data/Exemplar'
# output: result/fastp/fastp_summary.txt

cd $1

# run fastp
mkdir -p temp/fastp result/fastp

awk 'NR>1' group.txt|cut -f1|rush -j 10 \
      "fastp -i seq/{1}_1.fastq.gz -I seq/{1}_2.fastq.gz \
        -j temp/fastp/{1}_fastp.json -h temp/fastp/{1}_fastp.html \
        -o temp/fastp/{1}_1.fastq.gz  -O temp/fastp/{1}_2.fastq.gz \
        > temp/fastp/{1}.log 2>&1"

python3 ../../script/fastp_summary.py "temp/fastp" "result/fastp/fastp_summary.txt"