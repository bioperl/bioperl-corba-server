#!/usr/local/bin/perl -w
use strict;
use CORBA::ORBit idl => [ 'biocorba.idl' ];

my $ior_file = "seqfeatures.ior";
print STDERR "Got file $ior_file\n";
my $orb = CORBA::ORB_init("orbit-local-orb");

open(F,"$ior_file") || die "Could not open $ior_file";
my $ior = <F>;
chomp $ior;
close(F);

my $seq = $orb->string_to_object($ior);

my $vector = $seq->all_SeqFeatures(1);

my $iter = $vector->iterator();
while ( $iter->has_more ) {
    my $sf = $iter->next();
    print "Sf type is ", $sf->type(),
    " source is ", $sf->source, "\nstart=", $sf->start,
    ", end=", $sf->end, ", strand=", $sf->strand, "\n";
}
