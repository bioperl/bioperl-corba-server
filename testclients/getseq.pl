#!/usr/bin/perl -w
use strict;
use CORBA::ORBit idl => [ 'idl/seqcore.idl' ];
use Error qw(:try);
my $ior_file = "simpleseq.ior";
print STDERR "Got file $ior_file\n";
my $orb = CORBA::ORB_init("orbit-local-orb");

open(F,"$ior_file") || die "Could not open $ior_file";
my $ior = <F>;
chomp $ior;
close(F);

my $seq = $orb->string_to_object($ior);
try {
    print "seq is $seq, ",ref($seq), "\n";
    print "sequence all is ", $seq->seq(), "\n";
    print "length is ", $seq->get_length(), "\n";
    print "sequence is ", ( ! $seq->is_circular() ) ? 'not ' : '', 
    "circular\n";
    
    # WHAT THE HELL IS GOING ON!
    # when $end 7->10 fail on RH7.0 CORBA 0.5.7  
    # please test
    for my $end ( 3..12) {
	eval {
	    print STDERR "sequence 1,$end is ",$seq->sub_seq(1,$end),"\n";
	};
    }    
} catch bsane::OutOfBounds with {
    my $E = shift;
    print "exception ", $E->{'reason'}, "\n";
} catch bsane::RequestTooLarge with {
    my $E = shift;
    print "exception: reason=", $E->{'reason'}, "\n";

}
