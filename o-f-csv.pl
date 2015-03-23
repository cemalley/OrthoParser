#!/usr/bin/perl
### ORTHOPARSER 2015 ###
#Claire Malley March 18 2015
#Gather stats into CSV using OrthoParser output
use strict;
use warnings;
use List::Util qw(sum);
use Text::CSV;

my @opFiles = glob "OG*.fa";
my @CSV0 = ();
my @CSV1 = ();
my @CSV2 = ();
my @CSV3 = ();

my @header= ('GroupId', 'GroupSize', 'Species', 'GenesPerSpecies');
my $headerref = \@header;

my $csv = Text::CSV->new ( { binary => 1, sep_char => ',', eol    => "\n"} ) or die "Cannot use CSV: ".Text::CSV->error_diag ();

open $topcsv, ">:encoding(utf8)", "OrthoFinderStats.csv" or die "OrthoFinderStats.csv: $!";

$csv->print($topcsv, $headerref);

close $topcsv;


foreach my $opFiles (@opFiles){
    my @genesInGroup = ();
    open(my $infh, '<', $opFiles) or die $!;
        while(<$infh>){
            my $line = $_ unless ($_ eq "\n");
            chomp $line;
            if(/^>/){
                my $geneInGroup = substr $line, 1, 5;
                push @genesInGroup, $geneInGroup;
            }
        }
    my %counts;
    $counts{$_}++ for @genesInGroup;
    my $groupSize = $#genesInGroup + 1;
    my $groupName = substr $opFiles, 0, 8;
    my $specIncl = scalar keys %counts;
    my $avgGenesPerSpec = (sum values %counts)/($specIncl);
    push @CSV0, $groupName; #aka group ID
    push @CSV1, $groupSize;
    push @CSV2, $specIncl;
    push @CSV3, $avgGenesPerSpec;

my @bulk = (@CSV0, @CSV1, @CSV2, @CSV3);
my $bulk = \@bulk;

open $bulkcsv, ">>:encoding(utf8)", "OrthoFinderStats.csv" or die "OrthoFinderStats.csv: $!";

$csv->print($bulkcsv, $bulk);

close $bulkcsv;

@CSV0=();
@CSV1=();
@CSV2=();
@CSV3=();

close $infh;
}

exit;