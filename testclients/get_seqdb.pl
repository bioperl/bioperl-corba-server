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
my $vector = $db->get_PrimarySeqVector();
my $iter = $vector->iterator();

eval { 
    while ($iter->has_more ) {    
	my $seq = $iter->next;
	print $seq->seq,"\n";
	print "length is ", $seq->length, "\n";
	my $subseq = $seq->subseq(1,$seq->length - 10 );
	print "sub seq 1 .. ", $seq->length - 10 , " is ",
	$subseq, ":", length($subseq),"\n"; 
	print "accession is ", 
	$seq->accession_number, "\n";
	print "display id = ";
	print $seq->display_id;
	print "\n";
#    "\n\t  seq is",$seq->get_seq(),"\n";    
    }
};    
if( $@ ) {
    print "error\n";
} else {
    print "no error\n";
}

END {
    print "\n";
}
