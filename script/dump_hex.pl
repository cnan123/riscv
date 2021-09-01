#!/usr/bin/perl
use Getopt::Long;

#================================================================
#   Copyright (C) 2020 Sangfor Ltd. All rights reserved.
#   
#   Filename   ：dump_hex.pl
#   Auther     ：cnan
#   Creat_Data ：2020.11.08
#
#================================================================
my $base;
my $length;
my $width = 32;
my $filename = "hello_test.hex";
my $outfile = "instr_data.dat";

GetOptions (
    "base=s"    => \$base,    # numeric
    "length=s"  => \$length,      # string
    "width=s"   => \$width,
    "i=s"       => \$filename,
    "o=s"       => \$outfile
) or die("Error in command line arguments\n");

if( ! defined($base) ){ die("No base address"); }
if( ! defined($length) ){ die("No length"); }
if( ! defined($width) ){ die("No width"); }

$base =~ s/0x(.*)/\1/;
$length =~ s/0x(.*)/\1/;

$base = hex($base);
$length = hex($length);
my $end_address = $base + $length;
my @outdata;

open(MYFILE, $filename) || die ("could not open file0");
open(OUTFILE, ">", $outfile) || die ("could not open file0");

while(<MYFILE>){
    chmod $_;
    if( /:([0-9|a-f|A-F]{2})([0-9|a-f|A-F]{4})([0-9|a-f|A-F]{2})([0-9|a-f|A-F]+)([0-9|a-f|A-F]{2})/ ){
        $byte_length = $1;
        $low_address = $2;
        $type = $3;
        if($type eq '04'){ 
            $high_base = $4;
            print "extend base address: $high_base\n";
        } elsif( $type eq '00'){
            $data = $4;
            my $start = hex($high_base.$low_address);
            my $offset = hex($byte_length);
            for($i=0; $i<$offset; $i=$i+1){
                if( ( ($start+$i) >=$base) & ( ($start+$i) <$end_address) ){ 
                    $outdata[$start+$i-$base] = substr($data, 2*$i, 2);
                    #print "$outdata[$start+$i-$base]\n";
                    #print "$i\n";
                }
            }
        } elsif( $type eq '01'){
            print "file end\n";
        } elsif( $type eq '02'){
            print "extend section address\n";
             $high_base = $4;
        } elsif( $type eq '03'){
            print "start section address\n";
        } elsif( $type eq '05'){  
            print "start line address\n";
        }
    }
}

$byte = $width/8;
print "base : $base";
print "base : $end_address";
for(my $i=$base; $i<$end_address; $i=$i+$byte){
    for(my $j=0; $j<$byte; $j=$j+1){
        if( ! defined($outdata[$i + $byte-$j-1 - $base]) ){ print OUTFILE "00"; }
        else{ 
            print OUTFILE $outdata[$i + $byte-$j-1 - $base]; 
        }
    }
    print OUTFILE "\n";
}

print "DUMP DONE!!!\n";
