## snippy
# version 4.6.0

## input
# $1: work_dir, such as 'data/Exemplar'
# $2: species_name, such as 'Bifidobacterium_longum'
# $3: ref_filename, such as 'GCF_000196555.1_ASM19655v1_genomic.fna'
## output file
# temp/snippy/$2

## judge the Genome File contains multiple sequences and removes the plasmid sequence, leaving only the genome sequence
bash script/check_refgenome.sh $1 $2 $3


cd $1

# run snippy
mkdir -p temp/snippy/$2
mkdir -p result/snippy/$2


awk 'NR>1' result/snippy/$2/snp_species.txt | cut -f1 | rush -j 5 \
      "snippy --cpus 20 --outdir temp/snippy/$2/{1} -ref result/snippy/$2/$3 \
      --R1 temp/fastp/{1}_1.fastq.gz --R2 temp/fastp/{1}_2.fastq.gz"
# merge
snippy-core --prefix result/snippy/$2/core-snps temp/snippy/$2/* --ref result/snippy/$2/$3

# snippy-core includes only those samples in which 70% can be compared to a reference genome
snippy-core --prefix result/snippy/$2/core-snps --ref result/snippy/$2/$3 `awk -v prefix="temp/snippy/$2/" 'NR > 1 && !/Reference/ && ($3/$2 > 0.7) { printf "%s%s ", prefix,$1 }' result/snippy/$2/core-snps.txt`

# snp_matrix
cp result/snippy/$2/core-snps.tab result/snippy/$2/snp_matrix.txt

# sample.vcf.txt
mkdir result/snippy/$2/vcf.files
for i in `awk 'NR>1' result/snippy/$2/snp_species.txt | cut -f1`;do 
  if [ -f "temp/snippy/$2/$i/snps.filt.vcf" ]; then
    echo -e 'CHROM\tPOS\tREF\tALT\tQUAL\tTYPE' > result/snippy/$2/vcf.files/${i}.vcf.txt
    bcftools query -f '%CHROM\t%POS\t%REF\t%ALT\t%QUAL\t%INFO/TYPE\n' temp/snippy/$2/$i/snps.filt.vcf >> result/snippy/$2/vcf.files/${i}.vcf.txt
  fi
done

rm -rf temp/snippy/$2/*/reference
