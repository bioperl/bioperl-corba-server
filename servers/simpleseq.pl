#!/usr/local/bin/perl -w

use CORBA::ORBit idl => [ 'idl/biocorba.idl' ];
use Bio::CorbaServer::PrimarySeq;
use Bio::SeqIO;
use Bio::PrimarySeq;
use strict;

my $seqio = Bio::SeqIO->new( -format => 'Fasta', -fh => \*STDIN);
my $seq = $seqio->next_seq();
print STDERR "Got seq id '",$seq->id,"'\nseq='",$seq->seq,"'\n";


#build the actual orb and get the first POA (Portable Object Adaptor)
my $orb = CORBA::ORB_init("orbit-local-orb");
my $root_poa = $orb->resolve_initial_references("RootPOA");

#build a new CorbaServer object. This is a very light wrapper.
my $servant = Bio::CorbaServer::PrimarySeq->new('-poa' => $root_poa,
					     '-seq'  => $seq, 
					     '-no_destroy' => 1);

# this registers this object as a live object with the ORB
my $id = $root_poa->activate_object ($servant);

# we need to get the IOR of this object. The way to do this is to
# to get a client of the object (temp) and then get the IOR of the
# client
my $temp = $root_poa->id_to_reference ($id);
my $ior = $orb->object_to_string ($temp);

# write out the IOR. This is what we give to a different machine
my $ior_file = "simpleseq.ior";
open (OUT, ">$ior_file") || die "Cannot open file for ior: $!";
print OUT "$ior";
close OUT;

# tell everyone we are ready for it
print STDERR "Activating the ORB. IOR written to simpleseq.ior\n";

# and off we go. Woo Hoo!
$root_poa->_get_the_POAManager->activate;
$orb->run;
