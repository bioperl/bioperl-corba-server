#!/usr/local/bin/perl

use CORBA::ORBit idl => [ 'biocorba.idl' ];
use Error;
$ior_file = "seqdbsrv.ior";
print STDERR "Got file $ior_file\n";
$orb = CORBA::ORB_init("orbit-local-orb");

open(F,"$ior_file") || die "Could not open $ior_file";
$ior = <F>;
chomp $ior;
close(F);

my $db = $orb->string_to_object($ior);
print "db is $db\n";
my $vector = $db->get_PrimarySeqVector();
print "vector is $vector\n";
my $iter = $vector->iterator();
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
