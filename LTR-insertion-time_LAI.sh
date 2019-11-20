#!/bin/sh

##package: ltrharvest, ltr_finder, LTR_retriever

~/software/genometools-1.5.9/bin/gt suffixerator -db genome.fa -indexname genome -tis -suf -lcp -des -ssp -sds -dna
~/software/genometools-1.5.9/bin/gt ltrharvest -index genome -similar 90 -vic 10 -seed 20 -seqids yes -minlenltr 100 -maxlenltr 7000 -mintsd 4 -maxtsd 6 -motif TGCA -motifmis 1 > genome.fa.harvest.scn
~/software/genometools-1.5.9/bin/gt ltrharvest -index genome -similar 90 -vic 10 -seed 20 -seqids yes -minlenltr 100 -maxlenltr 7000 -mintsd 4 -maxtsd 6 > genome.harvest.nonTGCA.scn

~/software/LTR_FINDER.x86_64-1.0.5/ltr_finder -D 15000 -d 1000 -L 7000 -l 100 -p 20 -C -M 0.9 genome.fa > genome.fa.finder.cn

~/software/LTR_retriever-master/LTR_retriever -genome genome.fa -infinder genome.fa.finder.cn -inharvest genome.fa.harvest.scn ¨CnonTGCA genome.harvest.nonTGCA.scn
