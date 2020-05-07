#!/bin/sh

for i in *_1.clean.fq.gz; 
do
i=${i%_1.clean.fq.gz*}; 
hisat2 -p 20 --dta -x genome -1 ${i}_1.clean.fq.gz -2 ${i}_2.clean.fq.gz -S ${i}.sam 2>${i}.log 
done


for i in *.sam;
do 
i=${i%.sam*}; 
samtools sort -@ 20 -o ${i}.bam ${i}.sam 
done


for i in *.bam; 
do 
i=${i%.bam*}; stringtie -p 20 -G genome.gene.gff3 -o ${i}.gtf ${i}.bam -A gene_abund.tab -B -e
done
