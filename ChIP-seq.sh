###################################### ChIPseq analysis of Centromeres ######################################



#package: bowtie2, bedtools, samtools, SICER, macs14

##bowtie
mkdir bowtie &&  cd bowtie
wget https://sourceforge.net/projects/bowtie-bio/files/bowtie2/2.2.9/bowtie2-2.2.9-linux-x86_64.zip 
#Length: 27073243 (26M) [application/octet-stream]
#Saving to: "download"   ## I made a mistake here for downloading the bowtie2 
mv download  bowtie2-2.2.9-linux-x86_64.zip
unzip bowtie2-2.2.9-linux-x86_64.zip
 
##bedtools
mkdir bedtools &&  cd bedtools
wget https://github.com/arq5x/bedtools2/releases/download/v2.25.0/bedtools-2.25.0.tar.gz
tar -zxvf bedtools-2.25.0.tar.gz
cd bedtools2
make

##samtools
mkdir samtools &&  cd samtools
wget https://github.com/samtools/samtools/releases/download/1.3.1/samtools-1.3.1.tar.bz2 
tar xvfj samtools-1.3.1.tar.bz2 
cd samtools-1.3.1 
./configure --prefix=~/bin
make
make install

##samtools
mkdir samtools &&  cd samtools
wget https://github.com/samtools/samtools/releases/download/1.3.1/samtools-1.3.1.tar.bz2 
tar xvfj samtools-1.3.1.tar.bz2 
cd samtools-1.3.1 
./configure --prefix=~/bin
make
make install

##SICER
mkdir SICER &&  cd SICER
wget http://home.gwu.edu/~wpeng/Software.htm/SICER_V1.1.tar.bz2 
tar xvfj SICER_V1.1.tar.bz2 
cd SICER_V1.1 
PATHTO=/opt/

##macs2  
mkdir macs2 &&  cd macs2
wget https://pypi.python.org/packages/9f/99/a8ac96b357f6b0a6f559fe0f5a81bcae12b98579551620ce07c5183aee2c/MACS2-2.1.1.20160309.tar.gz
tar zxvf MACS2-2.1.1.20160309.tar.gz
cd MACS2-2.1.1.20160309
python setup.py install --user 



#analyses

##make file including chromosome number
touch tiqu_fasta.list

perl tiqu_fasta.pl tiqu_fasta.list AP85_genome/Sspon.HiC_chr_asm.fasta >ChrA.fa

ln -s ChrA.fa genome.fa

bowtie2-build genome.fa genome

##make file containing chrmosome length
bedtools makewindows -g Chr_length.list -w 10000 >genome_10Kb_region.bed

bowtie2 -p 2 -X 2000 -x genome -1 AP85_CHIP_rm_pcr_r1_trim.fq -2 AP85_CHIP_rm_pcr_r2_trim.fq -S AP85_CHIP_rm_pcr_r1_trim.sam 2>AP85_CHIP_rm_pcr_r1_trim_map.log
bowtie2 -p 2 -X 2000 -x genome -1 AP85_Input_rm_pcr_r1_trim.fq -2 AP85_Input_rm_pcr_r2_trim.fq -S AP85_Input_rm_pcr_r1_trim.sam 2>AP85_Input_rm_pcr_r1_trim_map.log

##export high quality reads
perl get_bt2_sam_uniq.pl AP85_CHIP_rm_pcr_r1_trim.sam AP85_CHIP_rm_pcr_r1_trim_uniq.sam 30
perl get_bt2_sam_uniq.pl AP85_Input_rm_pcr_r1_trim.sam AP85_Input_rm_pcr_r1_trim_uniq.sam 30

samtools view -F 4 -bS AP85_CHIP_rm_pcr_r1_trim_uniq.sam > AP85_CHIP_rm_pcr_r1_trim_uniq.bam
samtools sort AP85_CHIP_rm_pcr_r1_trim_uniq.bam -o AP85_CHIP_rm_pcr_r1_trim_uniq_sort.bam
samtools index AP85_CHIP_rm_pcr_r1_trim_uniq_sort.bam
bamToBed -i AP85_CHIP_rm_pcr_r1_trim_uniq_sort.bam >AP85_CHIP_rm_pcr_r1_trim_uniq_sort.bed

samtools view -F 4 -bS AP85_Input_rm_pcr_r1_trim_uniq.sam > AP85_Input_rm_pcr_r1_trim_uniq.bam
samtools sort AP85_Input_rm_pcr_r1_trim_uniq.bam -o AP85_Input_rm_pcr_r1_trim_uniq_sort.bam
samtools index AP85_Input_rm_pcr_r1_trim_uniq_sort.bam
bamToBed -i AP85_Input_rm_pcr_r1_trim_uniq_sort.bam >AP85_Input_rm_pcr_r1_trim_uniq_sort.bed

genomeCoverageBed -ibam AP85_CHIP_rm_pcr_r1_trim_uniq_sort.bam -bg -trackline -trackopts 'name="AP85_CHIP_rm_pcr_r1_trim_uniq_sort" color=250,0,0' >AP85_CHIP_rm_pcr_r1_trim_uniq_sort.bedGraph
genomeCoverageBed -ibam AP85_Input_rm_pcr_r1_trim_uniq_sort.bam -bg -trackline -trackopts 'name="AP85_Input_rm_pcr_r1_trim_uniq_sort" color=250,0,0' >AP85_Input_rm_pcr_r1_trim_uniq_sort.bedGraph

bedtools coverage -abam AP85_CHIP_rm_pcr_r1_trim_uniq_sort.bam -b genome_10Kb_region.bed | sort -k1,1 -k2,2n > AP85_CHIP_rm_pcr_r1_trim_uniq_sort_10Kb.mapstats
bedtools coverage -abam AP85_Input_rm_pcr_r1_trim_uniq_sort.bam -b genome_10Kb_region.bed | sort -k1,1 -k2,2n > AP85_Input_rm_pcr_r1_trim_uniq_sort_10Kb.mapstats

grep 'Chr' AP85_CHIP_rm_pcr_r1_trim_uniq_sort_10Kb.mapstats | awk '{if($4==0){print $0"\t0"}else{print $0"\t"$4/$5}}' >AP85_CHIP_rm_pcr_r1_trim_uniq_sort_10Kb.mapstats.readdensity
grep 'Chr' AP85_Input_rm_pcr_r1_trim_uniq_sort_10Kb.mapstats | awk '{if($4==0){print $0"\t0"}else{print $0"\t"$4/$5}}' >AP85_Input_rm_pcr_r1_trim_uniq_sort_10Kb.mapstats.readdensity

#know ChIP&input aligned total reads
awk -F'\t' '{OFS="\t"}NR==FNR{a[$1"\t"$2"\t"$3]=$8; next}{if($1"\t"$2"\t"$3 in a){C_ratio=$8/15714386; I_ratio=a[$1"\t"$2"\t"$3]/14029424; if(a[$1"\t"$2"\t"$3]>0){ratio=C_ratio/I_ratio; print $1,$2,$3,ratio}else{print $1,$2,$3,"0.00"}}}' AP85_Input_rm_pcr_r1_trim_uniq_sort_10Kb.mapstats.readdensity AP85_CHIP_rm_pcr_r1_trim_uniq_sort_10Kb.mapstats.readdensity > ChIP-vs-Input_ratio-corr_10k.txt

sh ~/software/SICER_V1.1/SICER/SICER.sh . AP85_CHIP_rm_pcr_r1_trim_uniq_sort.bed AP85_Input_rm_pcr_r1_trim_uniq_sort.bed . AP85_A 1 200 150 0.74 200 0.01
awk -F'\t' '{OFS="\t"}{if(($3-$2+1)>=1000 && $6<=0.00001 && $7>=5){print $1,$2,$3,"peak_"NR,$7}}' AP85_CHIP_rm_pcr_r1_trim_uniq_sort-W200-G200-islands-summary-FDR0.01 >AP85_peak_filter_W200-G200.bed

sh ~/software/SICER_V1.1/SICER/SICER.sh . AP85_CHIP_rm_pcr_r1_trim_uniq_sort.bed AP85_Input_rm_pcr_r1_trim_uniq_sort.bed . AP85_A 1 200 150 0.74 400 0.01
awk -F'\t' '{OFS="\t"}{if(($3-$2+1)>=1000 && $6<=0.00001 && $7>=5){print $1,$2,$3,"peak_"NR,$7}}' AP85_CHIP_rm_pcr_r1_trim_uniq_sort-W200-G400-islands-summary-FDR0.01 >AP85_peak_filter_W200-G400.bed

sh ~/software/SICER_V1.1/SICER/SICER.sh . AP85_CHIP_rm_pcr_r1_trim_uniq_sort.bed AP85_Input_rm_pcr_r1_trim_uniq_sort.bed . AP85_A 1 200 150 0.74 600 0.01
awk -F'\t' '{OFS="\t"}{if(($3-$2+1)>=1000 && $6<=0.00001 && $7>=5){print $1,$2,$3,"peak_"NR,$7}}' AP85_CHIP_rm_pcr_r1_trim_uniq_sort-W200-G600-islands-summary-FDR0.01 >AP85_peak_filter_W200-G600.bed

sh ~/software/SICER_V1.1/SICER/SICER.sh . AP85_CHIP_rm_pcr_r1_trim_uniq_sort.bed AP85_Input_rm_pcr_r1_trim_uniq_sort.bed . AP85_A 1 200 150 0.74 800 0.01
awk -F'\t' '{OFS="\t"}{if(($3-$2+1)>=1000 && $6<=0.00001 && $7>=5){print $1,$2,$3,"peak_"NR,$7}}' AP85_CHIP_rm_pcr_r1_trim_uniq_sort-W200-G800-islands-summary-FDR0.01 >AP85_peak_filter_W200-G800.bed

sh ~/software/SICER_V1.1/SICER/SICER.sh . AP85_CHIP_rm_pcr_r1_trim_uniq_sort.bed AP85_Input_rm_pcr_r1_trim_uniq_sort.bed . AP85_A 1 200 150 0.74 1000 0.01
awk -F'\t' '{OFS="\t"}{if(($3-$2+1)>=1000 && $6<=0.00001 && $7>=5){print $1,$2,$3,"peak_"NR,$7}}' AP85_CHIP_rm_pcr_r1_trim_uniq_sort-W200-G1000-islands-summary-FDR0.01 >AP85_peak_filter_W200-G1000.bed

sh ~/software/SICER_V1.1/SICER/SICER.sh . AP85_CHIP_rm_pcr_r1_trim_uniq_sort.bed AP85_Input_rm_pcr_r1_trim_uniq_sort.bed . AP85_A 1 400 150 0.74 400 0.01
awk -F'\t' '{OFS="\t"}{if(($3-$2+1)>=1000 && $6<=0.00001 && $7>=5){print $1,$2,$3,"peak_"NR,$7}}' AP85_CHIP_rm_pcr_r1_trim_uniq_sort-W400-G400-islands-summary-FDR0.01 >AP85_peak_filter_W400-G400.bed

sh ~/software/SICER_V1.1/SICER/SICER.sh . AP85_CHIP_rm_pcr_r1_trim_uniq_sort.bed AP85_Input_rm_pcr_r1_trim_uniq_sort.bed . AP85_A 1 400 150 0.74 800 0.01
awk -F'\t' '{OFS="\t"}{if(($3-$2+1)>=1000 && $6<=0.00001 && $7>=5){print $1,$2,$3,"peak_"NR,$7}}' AP85_CHIP_rm_pcr_r1_trim_uniq_sort-W400-G800-islands-summary-FDR0.01 >AP85_peak_filter_W400-G800.bed

sh ~/software/SICER_V1.1/SICER/SICER.sh . AP85_CHIP_rm_pcr_r1_trim_uniq_sort.bed AP85_Input_rm_pcr_r1_trim_uniq_sort.bed . AP85_A 1 400 150 0.74 1200 0.01
awk -F'\t' '{OFS="\t"}{if(($3-$2+1)>=1000 && $6<=0.00001 && $7>=5){print $1,$2,$3,"peak_"NR,$7}}' AP85_CHIP_rm_pcr_r1_trim_uniq_sort-W400-G1200-islands-summary-FDR0.01 >AP85_peak_filter_W400-G1200.bed

sh ~/software/SICER_V1.1/SICER/SICER.sh . AP85_CHIP_rm_pcr_r1_trim_uniq_sort.bed AP85_Input_rm_pcr_r1_trim_uniq_sort.bed . AP85_A 1 600 150 0.74 600 0.01
awk -F'\t' '{OFS="\t"}{if(($3-$2+1)>=1000 && $6<=0.00001 && $7>=5){print $1,$2,$3,"peak_"NR,$7}}' AP85_CHIP_rm_pcr_r1_trim_uniq_sort-W600-G600-islands-summary-FDR0.01 >AP85_peak_filter_W600-G600.bed

sh ~/software/SICER_V1.1/SICER/SICER.sh . AP85_CHIP_rm_pcr_r1_trim_uniq_sort.bed AP85_Input_rm_pcr_r1_trim_uniq_sort.bed . AP85_A 1 600 150 0.74 1200 0.01
awk -F'\t' '{OFS="\t"}{if(($3-$2+1)>=1000 && $6<=0.00001 && $7>=5){print $1,$2,$3,"peak_"NR,$7}}' AP85_CHIP_rm_pcr_r1_trim_uniq_sort-W600-G1200-islands-summary-FDR0.01 >AP85_peak_filter_W600-G1200.bed

sh ~/software/SICER_V1.1/SICER/SICER.sh . AP85_CHIP_rm_pcr_r1_trim_uniq_sort.bed AP85_Input_rm_pcr_r1_trim_uniq_sort.bed . AP85_A 1 800 150 0.74 800 0.01
awk -F'\t' '{OFS="\t"}{if(($3-$2+1)>=1000 && $6<=0.00001 && $7>=5){print $1,$2,$3,"peak_"NR,$7}}' AP85_CHIP_rm_pcr_r1_trim_uniq_sort-W800-G800-islands-summary-FDR0.01 >AP85_peak_filter_W800-G800.bed

macs14 -t AP85_CHIP_rm_pcr_r1_trim_uniq_sort.bam -c AP85_Input_rm_pcr_r1_trim_uniq_sort.bam -n AP85_A -g 7.3e8 --nomodel --shiftsize=73 -B -S 2>peakcall.log

more AP85_peaks.xls | awk '{if($0~/^#/ || $0~/^Chr/){print}else if($4>=1000 && $7>=50 && $9<=1){print}}'|less -S > AP85_peaks_filt.macs.xls 			

awk 'NR==FNR{if($0~/^Chr/){a[$1"\t"$2"\t"$3]; next}}{if($1"\t"($2+1)"\t"$3 in a){print $0}}' AP85_peaks_filt.macs.xls AP85_peaks.bed | less -S > AP85_peaks_filt.macs.bed
			
