#!/bin/sh

#PBS -N centromere
#PBS -l nodes=1:ppn=20
#PBS -o pbs_out.$PBS_JOBID
#PBS -e pbs_err.$PBS_JOBID
#PBS -l walltime=12000:00:00
#PBS -q batch

cd $PBS_O_WORKDIR


#blasnt6_to_cluster_nu.pl(sequenced length) & list2rate.pl(chip input numbers) & base_id_list_get_seq_part.pl

ln -s Galaxy370-[Contigs_from_dataset_343_based_on_clustering].fasta CLcontigs.fa

#blast

formatdb -i CLcontigs.fa -p F

ln -s ChIP.clean.fa raic_r1.fa

blastall -p blastn -i raic_r1.fa -d CLcontigs.fa -o raic_blastn_out.txt -e 1e-5 -F F -r 2 -m 8 -v 1 -b 1

ln -s input.clean.fa raii_r1.fa

blastall -p blastn -i raii_r1.fa -d CLcontigs.fa -o raii_blastn_out.txt -e 1e-5 -F F -r 2 -m 8 -v 1 -b 1

awk '!a[$1]++' raic_blastn_out.txt > raic_blastn_out_uniq.txt

awk '!a[$1]++' raii_blastn_out.txt > raii_blastn_out_uniq.txt

perl blasnt6_to_cluster_nu.pl raic_blastn_out_uniq.txt

perl blasnt6_to_cluster_nu.pl raii_blastn_out_uniq.txt

perl list2rate.pl raic_blastn_out_uniq.txt.cluster_reads_list.txt raii_blastn_out_uniq.txt.cluster_reads_list.txt 2000

#open chip_input_CL_min2000_uniq.txt & excel & make a log "CL.list" inculude CLs

awk -F'Contig' '{print $1"\tContig"$2}' raii_blastn_out_uniq.txt.cluster_contig_reads_list.txt >1

awk -F'\t' '{OFS="\t"}NR==FNR{a[$1]; next}{if($1 in a){print $0}}' CL.list 1 >2

awk '{key=$1; s=$0; if (a[key]<$3){b[key]=s;a[key]=$3}} END{for (i in b) print b[i]}' 2 >3

awk '{print $1$2}' 3 >4

perl tiqu_fasta.pl CLcontigs.fa 4 out.fa

