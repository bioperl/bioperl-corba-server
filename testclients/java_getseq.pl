#!/usr/local/bin/perl

use CORBA::ORBit idl => [ 'biocorba.idl' ];

$ior_file = "/genome3/jason/proj/bio/biojava/biojava-live/demos/seqdbsrv.ior";
#simpleseq.ior";
print STDERR "Got file $ior_file\n";
$orb = CORBA::ORB_init("orbit-local-orb");

open(F,"$ior_file") || die "Could not open $ior_file";
$ior = <F>;
chomp $ior;
close(F);

$seqdb = $orb->string_to_object($ior);
$piterator = $seqdb->make_PrimarySeqIterator();
print "iterator is ", ref($piterator), "\n";

while( $piterator->has_more == 1 ) {
    $seq = $piterator->next();
    print "sequence name is ",$seq->display_id,"\n";
    print "  seq is",$seq->get_seq(),"\n";
}


