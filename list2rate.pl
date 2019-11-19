#!/usr/bin/perl
use warnings;
use strict;
use 5.010;
use File::Basename;


my ($chip,$input,$ch_reads_min)= @ARGV;
my $dir=dirname $chip;

my $out=$dir."/chip_input_CL.txt";
my $out_min=$dir."/chip_input_CL_min".$ch_reads_min.".txt";

open CH, $chip or die "$!";
open IP, $input or die "$!";
open OUT, ">$out" or die "$!";
open MIN, ">$out_min" or die "$!";

my %ip_cl_reads;
my $ip_title=<IP>;
while(<IP>){
	chomp;
	my ($ip_cl,$ip_ctg,$ip_reads)=split /\t/,$_;
	push @{$ip_cl_reads{$ip_cl}},($ip_ctg,$ip_reads);
}


my $ch_title=<CH>;
say OUT "CL\tchip_ctg\tchip_reads\tchip_rate\ttinput_ctg\tinput_reads\tinput_rate\tchip_rate\\input_rate";
say MIN "CL\tchip_ctg\tchip_reads\tchip_rate\ttinput_ctg\tinput_reads\tinput_rate\tchip_rate\\input_rate";
while(<CH>){
	chomp;
	my ($ch_cl,$ch_ctg,$ch_reads)=split /\t/,$_;
	my $ch_rate=$ch_reads/20616348;
	if(exists $ip_cl_reads{$ch_cl}){
		my $ip_rate=($ip_cl_reads{$ch_cl}->[1])/6301625;
		my $rate=$ch_rate/$ip_rate;
		say OUT  "$_\t$ch_rate\t$ip_cl_reads{$ch_cl}->[0]\t$ip_cl_reads{$ch_cl}->[1]\t$ip_rate\t$rate";
		if ($ch_reads>=$ch_reads_min){
			say MIN  "$_\t$ch_rate\t$ip_cl_reads{$ch_cl}->[0]\t$ip_cl_reads{$ch_cl}->[1]\t$ip_rate\t$rate";
		}else{
			#
		}
	}else{
		say OUT "$_\t$ch_rate\t0\t0\t0\t-";
		say MIN "$_\t$ch_rate\t0\t0\t0\t-" if $ch_reads>=$ch_reads_min;
	}
}


close CH;
close IP;
close OUT;
close MIN;
