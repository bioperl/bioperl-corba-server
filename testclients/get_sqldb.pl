#!/usr/bin/perl -w
use strict;

use CORBA::ORBit idl => [ 'idl/biocorba.idl' ];
use Error qw(:try);

my $ior_file = "sqldbsrv.ior";
print STDERR "Got file $ior_file\n";
my $orb = CORBA::ORB_init("orbit-local-orb");

open(F,"$ior_file") || die "Could not open $ior_file";
my $ior = <F>;
chomp $ior;
close(F);
my $seqdb = $orb->string_to_object($ior);
print "seqdb is $seqdb\n";
try {
    my $seq = $seqdb->resolve('U63596');
    print "seq is ", $seq->seq(), "\n";
    my $collection = $seq->get_seq_features();
    my $iter;
    my $annot_iter = $collection->get_annotations(1000,$iter);
    while( my $sf = $annot_iter->next() ) {
	print "seqf is ", $sf->get_name(), " ", $sf->get_value, "\n";
    }
} catch bsane::IdentifierDoesNotExist with {
    my $E = shift;
    print "exception ", $E->{'reason'}, "\n";
} 
