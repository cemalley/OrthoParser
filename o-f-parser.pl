#!/usr/bin/perl
### ORTHOPARSER 2015 ###
#Claire Malley March 2015
#parser for the OrthoFinder .txt output file
#usage: perl o-f-parsel.pl OrthologousGroups.txt
#purpose: store orthogroup IDs and containing genes into a hash.

use warnings;
use Bio::SeqIO;
use File::Copy qw(move);
use Archive::Tar;
use File::Slurp;

print "Welcome to OrthoParser. Please enter the full path to the protein files run in OrthoFinder:";
my $fastaPath = <STDIN>;
chomp $fastaPath;

###Make sure formatting of path is correct###
if ($fastaPath =~ /\/$/){chop($fastaPath);}
if ($fastaPath =~ /^\w/){$fastaPath = "/$fastaPath";}

my @fastaFiles = glob "$fastaPath/*.fa";

###Store all genes into a hash###
my %sequences;
my @genes;

###Save all protein sequences in one hash###
foreach my $fastaFiles (@fastaFiles){
    my $seqio = Bio::SeqIO->new(-file => "$fastaFiles", -format => "fasta");
    
    while(my$seqobj = $seqio->next_seq) {
        my $geneId  = $seqobj->display_id;
        my $seq = $seqobj->seq;
        $sequences{$geneId} = $seq;
        push @genes, $geneId;
    }
}

######Done storing protein sequences###
######Start processing OrthologousGroups.txt###

my $infile = $ARGV[0];
my %orthoGroup;
open (FILE, $infile) or die ("Can't open file: $!");
while (<FILE>){
    my $line = $_ unless ($_ eq "\n");
	chomp $line;
    my ($groupId, $groupGenes) = (split /:\s/, $line);
    $orthoGroup{$groupId} = $groupGenes;
    #my @groupGenes = split / /, $groupGenes, 2;
}
close FILE;

foreach my $i ( sort keys %orthoGroup ) {
	my $outfile = "$i.fa";
	open(my $outfh, '>', $outfile) or die $!;
		#print $outfh "@{$orthoGroup{$i}}";
		my $content = "$orthoGroup{$i}";
		my @content = split / /, $content;
		foreach $content(@content){
		$| = 1;
		print $outfh ">$content\n$sequences{$content}\n";
		}
	close $outfh;
}

my $size = scalar keys %orthoGroup;

print "\n OrthoFinder found $size orthogroups.\n";
print "\n Orthogroups written to file.\n\n";

exit;
