#!/usr/local/bin/perl

#!/usr/local/lib/perl

use Bio::CorbaServer::PrimarySeqIterator;
use Bio::SeqIO;

use CORBA::ORBit idl => [ 'biocorba.idl' ];

#build the actual orb and get the first POA (Portable Object Adaptor)
$orb = CORBA::ORB_init("orbit-local-orb");
$root_poa = $orb->resolve_initial_references("RootPOA");

$seqio  = Bio::SeqIO->new( '-format' => 'fasta',-fh => \*STDIN );

$servant = Bio::CorbaServer::PrimarySeqIterator->new('-poa' => $root_poa,
						     '-seqio' => $seqio,
						     '-no_destroy' => 1);

# this registers this object as a live object with the ORB
my $id = $root_poa->activate_object ($servant);

# we need to get the IOR of this object. The way to do this is to
# to get a client of the object (temp) and then get the IOR of the
# client
$temp = $root_poa->id_to_reference ($id);
my $ior = $orb->object_to_string ($temp);

# write out the IOR. This is what we give to a different machine
$ior_file = "bioiterator.ior";
open (OUT, ">$ior_file") || die "Cannot open file for ior: $!";
print OUT "$ior";
close OUT;

# tell everyone we are ready for it
print STDERR "Activating the ORB. IOR written to bioiterator.ior\n";

# and off we go. Woo Hoo!
$root_poa->_get_the_POAManager->activate;
$orb->run;
