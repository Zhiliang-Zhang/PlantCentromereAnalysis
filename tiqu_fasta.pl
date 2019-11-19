#! /usr/bin/perl -w  
use strict;  
die "perl $0 <lst><fa>\n" unless  @ARGV==2;  
my ($lst,$fa)=@ARGV;  
open IN,$lst||die;  
my %ha;  
map{chomp;$ha{(split)[0]}=1}<IN>;  
close IN;  
  
$fa=~/gz$/?(open IN,"gzip -cd $fa|"||die):(open IN,$fa||die);  
$/=">";<IN>;$/="\n";  
my %out;  
while(<IN>){  
    my $info=$1 if(/^(\S+)/);  
    $/=">";  
    my $seq=<IN>;  
    $/="\n";  
    $seq=~s/>|\r|\*//g;  
    print ">$info\n$seq" if(exists $ha{$info} && ! exists $out{$info});  
    $out{$info}=1;  
}  
close IN;  