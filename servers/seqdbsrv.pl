#!/usr/local/bin/perl 

use Bio::CorbaServer::PrimarySeqDB;
use Bio::CorbaServer::SeqDB;

# lets make the indexfile from the multifa.seq
use Bio::Index::Fasta;
my $dir = `pwd`;
chomp($dir);
unlink $tst_index_file;
my $tst_index_file = "$dir/t/testIndex.dbm";
my $ind = Bio::Index::Fasta->new(-filename => $tst_index_file, 
				 -write_flag => 1, 
				 -verbose => 1);
$ind->make_index("$dir/t/multifa.seq");
# got to make sure the entire file is synced to disk before proceeeding...
$ind = undef;

# lets go CORBA-ing

use CORBA::ORBit idl => [ 'biocorba.idl' ];

#build the actual orb and get the first POA (Portable Object Adaptor)
$orb = CORBA::ORB_init("orbit-local-orb");
$root_poa = $orb->resolve_initial_references("RootPOA");

# make a Fast index object

my $seqdb = Bio::Index::Fasta->new(-filename => $tst_index_file, 
				 -write_flag => 0, 
				 -verbose => 1);

					
$servant = Bio::CorbaServer::SeqDB->new('-poa'        => $root_poa,
					'-name'       => 'test_db', 
					'-seqdb'      => $seqdb, 
					'-no_destroy' => 1);

# this registers this object as a live object with the ORB
my $id = $root_poa->activate_object ($servant);

# we need to get the IOR of this object. The way to do this is to
# to get a client of the object (temp) and then get the IOR of the
# client
my $temp = $root_poa->id_to_reference ($id);
my $ior = $orb->object_to_string ($temp);

# write out the IOR. This is what we give to a different machine
$ior_file = "seqdbsrv.ior";
open (OUT, ">$ior_file") || die "Cannot open file for ior: $!";
print OUT "$ior";
close OUT;

# tell everyone we are ready for it
print STDERR "Activating the ORB. IOR written to $ior_file\n";

# and off we go. Woo Hoo!
$root_poa->_get_the_POAManager->activate;
$orb->run;

END { 
    unlink "$dir/$tst_index_file";
}
