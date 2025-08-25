#!/usr/local/bin/perl -w
# Usage: perl format_stan.pl input.txt output.txt
# Replaces tabs within quoted strings with spaces, preserving tab separation elsewhere.

$input_file=$ARGV[0];
$output_file=$ARGV[1];
chomp ($input_file);
open (input_data, "<$input_file") or die "Couldn't open: $!";
chomp ($output_file);
open (output_result, ">$output_file") or die "Couldn't open: $!";

$line='';
$i=0;
$temp='';
$linestan='';
while (1) {
    $i++;
    chomp ($line=<input_data>);
    $linestan='';
    while ($line=~/".*?"/) {
        $linestan.=$`;
        $temp=$&;
        $line=$';
        $temp=~s/\t/ /g;
        $linestan.=$temp;
    }
    $linestan.=$line;
    print output_result "$linestan\n";
    if (0==($i%1000000)) {
        print ("$i lines processed\n");
    }
    if (eof) {
        last;
    }
}
close input_data;
close output_result;
if (0!=($i%1000000)) {
    print ("$i lines processed\n");
}
print ("All done\n");
exit;