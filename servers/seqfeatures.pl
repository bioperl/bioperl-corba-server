#!/usr/local/bin/perl -w
use strict;
use Bio::SeqIO;

my $seq = Bio::SeqIO->new('-format' => 'genbank',
			  '-file'   => 't/test.genbank')->next_seq;

# lets go CORBA-ing

use CORBA::ORBit idl => [ 'biocorba.idl' ];

#build the actual orb and get the first POA (Portable Object Adaptor)
my $orb = CORBA::ORB_init("orbit-local-orb");
my $root_poa = $orb->resolve_initial_references("RootPOA");

use Bio::CorbaServer::Seq;

# make a Fast index object
my $servant = new Bio::CorbaServer::Seq('-poa' => $root_poa,
					'-seq' => $seq);
# this registers this object as a live object with the ORB
my $id = $root_poa->activate_object ($servant);

# we need to get the IOR of this object. The way to do this is to
# to get a client of the object (temp) and then get the IOR of the
# client
my $temp = $root_poa->id_to_reference ($id);
my $ior = $orb->object_to_string ($temp);

# write out the IOR. This is what we give to a different machine
my $ior_file = "seqfeatures.ior";
open (OUT, ">$ior_file") || die "Cannot open file for ior: $!";
print OUT "$ior";
close OUT;

# tell everyone we are ready for it
print STDERR "Activating the ORB. IOR written to $ior_file\n";

# and off we go. Woo Hoo!
$root_poa->_get_the_POAManager->activate;
$orb->run;
