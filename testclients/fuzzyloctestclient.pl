#!/usr/local/bin/perl -w
use strict;
use CORBA::ORBit idl => [ 'biocorba.idl' ];

my $ior_file = "fuzzyloc.ior";
print STDERR "Got file $ior_file\n";
my $orb = CORBA::ORB_init("orbit-local-orb");

open(F,"$ior_file") || die "Could not open $ior_file";
my $ior = <F>;
chomp $ior;
close(F);

my $seq = $orb->string_to_object($ior);

my $seqfvector = $seq->all_SeqFeatures();
my $iter = $seqfvector->iterator;
while( $iter->has_more ) {
    my $seqf = $iter->next;
    print "type =", $seqf->type, ", source =", $seqf->source,
    ", start =", $seqf->start, ", end =", $seqf->end, ", strand=", 
    $seqf->strand, "\n";

    print "qualifiers are :\n";
    foreach my $qual ( @{$seqf->qualifiers} ) {
	print "\t", $qual->{'name'}, " ", join(",", @{$qual->{'values'}}), "\n";
    }
    print "my locations are:\n";
    foreach my $location ( @{$seqf->locations} ) {
	print "start =", $location->{'start'}->{'position'}, 
	" ext=", $location->{'start'}->{'extension'}, " fuzzy=", 
	$location->{'start'}->{'fuzzy'}, "\n";
    }
	
}




