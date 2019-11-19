#!/usr/bin/perl
use warnings;
use strict;
use 5.010;
use File::Basename;

my $in= shift @ARGV;
my $dir=dirname $in;
my $file=basename $in;

my $out1=$dir."/$file.cluster_reads_list.txt";
my $out2=$dir."/$file.cluster_contig_reads_list.txt";

open IN, $in or die "$!";
open OUT1, ">$out1" or die "$!";
open OUT2, ">$out2" or die "$!";

# blastn outfmt=6
# Fields: query id, subject id, % identity, alignment length, mismatches, gap opens, q. start, q. end, s. start, s. end, evalue, bit score

my (%cl_reads,%cl_ctg_reads);
my ($reads,$total);

while(<IN>){
	$total++;
	my ($cl_ctg,$idt,$q_start,$q_end)=(split /\t/,$_)[1,2,6,7];
	my $cov=($q_end-$q_start+1)/150;
	if($idt >= 90 && $cov >= 0.55 ){
		 $reads++;
		my ($cl,$ctg)=($1,$2) if $cl_ctg=~/(CL\d+)(Contig\d+)/;
		$cl_reads{$cl}++;
		$cl_ctg_reads{$cl}->{$cl_ctg}++;
	}
}

say OUT1 "Cluster\tcontigs_nu\tmapped_reads_nu";
say OUT2 "Cluster_contig\tmapped_reads_nu";
foreach my $cluster (sort {$a <=> $b } (map {/(\d+)/} keys %cl_reads)){
	$cluster="CL"."$cluster";
	my %ctg_reads=%{$cl_ctg_reads{$cluster}};

	my $ctg_nu=0;
	foreach my $ctg (sort {$a <=> $b } (map {/(\d+)$/}  keys %ctg_reads)){
		my $ctg=$cluster."Contig$ctg";
		say OUT2 "$ctg\t$ctg_reads{$ctg}";
		$ctg_nu++;
			
	}

		say OUT1 "$cluster\t$ctg_nu\t$cl_reads{$cluster}";

} 

say "$reads out of $total are mapped (coverage>=0.55 and identity>= 0.9).";
say "$reads/$total= ". $reads/$total;
say "";

close IN;
close OUT1;
close OUT2;
