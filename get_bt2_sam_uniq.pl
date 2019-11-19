#!/usr/bin/perl
use warnings;
use strict;
use 5.010;

# 2014-8-21
# yuly & zeng zixian
# get bt2_sam uniquely mapped reads: AS>XS,/YT:Z:CP/,mapping quality>24
# usage: perl sam uniq_sam 40
#


my %outp1=();

open IN,"$ARGV[0]" or die;
open OUT,">$ARGV[1]" or die;
my $mq=$ARGV[2];

while(<IN>){
    s/\n//g;
    my @t=split /\t/;
    my $bestscore="EEE";
    my $secondscore=-999;
    my $pairflag=0;
    for(my $i=11;$i<scalar @t;$i++){
        if($t[$i]=~/AS\:i\:(.*)/){
                $bestscore=$1;
            }
        if($t[$i]=~/XS\:i\:(.*)/){
		$secondscore=$1;
            }
        if($t[$i]=~/YT:Z:CP/){
                $pairflag=1;
            }                    
    }
    
    next if ($bestscore eq "EEE" || $pairflag==0);

    if($bestscore > $secondscore && $t[4]>$mq){ #&& $bestscore>-1
        #print;
        #print "\n";
        $outp1{$t[0]}=1; 
    }
        
}
close IN;

open IN,"$ARGV[0]" or die;
while(<IN>){
	print OUT $_ if  /^@/;
    my @t=split /\t/;
    if(exists $outp1{$t[0]} and  $outp1{$t[0]} eq 1){
        print OUT $_;
    }
}

close IN;
close OUT;
