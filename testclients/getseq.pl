#!/usr/local/bin/perl

use CORBA::ORBit idl => [ 'biocorba.idl' ];

$ior_file = "simpleseq.ior";
print STDERR "Got file $ior_file\n";
$orb = CORBA::ORB_init("orbit-local-orb");

open(F,"$ior_file") || die "Could not open $ior_file";
$ior = <F>;
chomp $ior;
close(F);

$seq = $orb->string_to_object($ior);

print "sequence name is ",$seq->display_id,"\n";
print "  seq is",$seq->get_seq(),"\n";


