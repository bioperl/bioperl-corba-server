#!/usr/local/bin/perl -w
use strict;

use Bio::CorbaServer::Server;

# lets make the indexfile from the multifa.seq
use Bio::Index::GenBank;
my $tst_index_file = "/tmp/index.idx";
unlink($tst_index_file);
my $verbose = 1;
my $ind = Bio::Index::GenBank->new(-filename => $tst_index_file, 
				   -write_flag => 1, 
				   -verbose => $verbose);
$ind->make_index("t/test.genbank");
# got to make sure the entire file is synced to disk before proceeeding...
my $ior_file = "seqgetprofile.ior";

my $server = new Bio::CorbaServer::Server ( -verbose => $verbose,
					    -idl => 'idl/biocorba.idl',
					    -ior => $ior_file,
					    -orbname=> 'orbit-local-orb');
my $seqdb = $server->new_object(-object=>'Bio::CorbaServer::SeqDB',
				-args => [ '-seqdb' => $ind ]);

$server->start();

END {
    unlink $ior_file;
}
