#!/usr/local/bin/perl

use CORBA::ORBit idl => [ 'biocorba.idl' ];

$ior_file = "bioiterator.ior";
print STDERR "Got file $ior_file\n";
$orb = CORBA::ORB_init("orbit-local-orb");

open(F,"$ior_file") || die "Could not open $ior_file";
$ior = <F>;
chomp $ior;
close(F);

$piterator = $orb->string_to_object($ior);

while( $piterator->has_more == 1 ) {
    $seq = $piterator->next();
    print "Got ",$seq->display_id,":",$seq->seq,"\n";
}




