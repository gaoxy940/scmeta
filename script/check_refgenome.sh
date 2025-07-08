#!/bin/bash
## judge a .fna Genome File contains multiple sequences and removes the plasmid sequence, leaving only the genome sequence

## input
# $1: work_dir, such as 'data/Exemplar'
# $2: species_name, such as 'Bifidobacterium_longum'
# $3: ref_filename, such as 'Bifidobacterium_longum.fna'


cd $1
cd result/snippy/$2


input_file=$3
output_file="ref_genome_checked.fna"


if [[ ! -f "$input_file" ]]; then
  exit 1
fi


keep_sequence=false

while IFS= read -r line || [[ -n "$line" ]]; do

  if [[ "$line" =~ ^\> ]]; then

    if [[ "$line" == *"chromosome"* ]]; then
      keep_sequence=true
      echo "$line" >> "$output_file"
    else
      keep_sequence=false
    fi

  elif $keep_sequence; then
    echo "$line" >> "$output_file"

  fi
  
done < "$input_file"

if [[ -f "$output_file" ]]; then
  mv "$input_file" "ref_genome_prim.fna"
  mv "$output_file" "$input_file"
fi