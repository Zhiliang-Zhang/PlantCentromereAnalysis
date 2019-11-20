#!/bin/sh

samtools merge F_DR.bam DR.bam
samtools sort DR.bam -o DR_sort.bam
samtools index DR_sort.bam
stringtie -p 20 -G genome.gene.gff3 -o DR_sort.gtf DR_sort.bam -A DR_gene_abund.tab -B -e

samtools merge F_CK.bam CK.bam
samtools sort CK.bam -o CK_sort.bam
samtools index CK_sort.bam
stringtie -p 20 -G genome.gene.gff3 -o CK_sort.gtf CK_sort.bam -A CK_gene_abund.tab -B -e

