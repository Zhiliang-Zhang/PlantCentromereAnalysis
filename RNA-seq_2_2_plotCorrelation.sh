#!/bin/sh

#PBS -N 0
#PBS -l nodes=1:ppn=20
#PBS -o pbs_out.$PBS_JOBID
#PBS -e pbs_err.$PBS_JOBID
#PBS -l walltime=1000:00:00
#PBS -q batch

cd $PBS_O_WORKDIR

samtools index *.bam

multiBamSummary bins --bamfiles DR-1.bam DR-2.bam DR-3.bam --minMappingQuality 30 --binSize=100 --labels DR-1 DR-2 DR-3 -out readCounts.npz --outRawCounts readCounts.tab

plotCorrelation -in readCounts.npz --corMethod pearson --plotTitle "Pearson Correlation of Read Counts" --whatToPlot scatterplot -o DR-scatterplot_PearsonCorr.pdf --outFileCorMatrix DR-PearsonCorr.tab


multiBamSummary bins --bamfiles CK-1.bam CK-2.bam CK-3.bam --minMappingQuality 30 --binSize=100 --labels CK-1 CK-2 CK-3 -out readCounts.npz --outRawCounts readCounts.tab

plotCorrelation -in readCounts.npz --corMethod pearson --plotTitle "Pearson Correlation of Read Counts" --whatToPlot scatterplot -o CK-scatterplot_PearsonCorr.pdf --outFileCorMatrix CK-PearsonCorr.tab

