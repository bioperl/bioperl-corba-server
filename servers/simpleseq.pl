#!/usr/local/bin/perl -w

use Bio::CorbaServer::PrimarySeq;
use CORBA::ORBit idl => [ 'biocorba.idl' ];
use Bio::SeqIO;
use Bio::PrimarySeq;

$seqio = Bio::SeqIO->new( -format => 'Fasta', -fh => \*STDIN);
$seq = $seqio->next_seq();
print STDERR "Got seq",$seq->id,"seq",$seq->seq,"\n";


#build the actual orb and get the first POA (Portable Object Adaptor)
$orb = CORBA::ORB_init("orbit-local-orb");
$root_poa = $orb->resolve_initial_references("RootPOA");

#build a new CorbaServer object. This is a very light wrapper.
$servant = Bio::CorbaServer::PrimarySeq->new($root_poa,$seq, no_destroy => 1);

# this registers this object as a live object with the ORB
my $id = $root_poa->activate_object ($servant);


# we need to get the IOR of this object. The way to do this is to
# to get a client of the object (temp) and then get the IOR of the
# client
$temp = $root_poa->id_to_reference ($id);
my $ior = $orb->object_to_string ($temp);

# write out the IOR. This is what we give to a different machine
$ior_file = "simpleseq.ior";
open (OUT, ">$ior_file") || die "Cannot open file for ior: $!";
print OUT "$ior";
close OUT;

# tell everyone we are ready for it
print STDERR "Activating the ORB. IOR written to simpleseq.ior\n";

# and off we go. Woo Hoo!
$root_poa->_get_the_POAManager->activate;
$orb->run;






