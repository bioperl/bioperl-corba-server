#!/usr/local/bin/perl

use CORBA::ORBit idl => [ 'biocorba.idl' ];
use Error;
$ior_file = "simpleseq.ior";
print STDERR "Got file $ior_file\n";
$orb = CORBA::ORB_init("orbit-local-orb");

open(F,"$ior_file") || die "Could not open $ior_file";
$ior = <F>;
chomp $ior;
close(F);

my $db = $orb->string_to_object($ior);

my $iter = $db->make_PrimarySeqIterator;
print "iter is $iter\n";

while ($iter->has_more ) {
    my $seq = $iter->next;
    print "display id = ", $seq->display_id,"\n\t  seq is",$seq->get_seq(),"\n";    
}

if( $@ ) {
    print "error\n";
} else {
    print "no error\n";
}

END {
    print "\n";
}
