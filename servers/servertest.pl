#!/usr/local/bin/perl -w
use strict;

use Bio::CorbaServer::Server;

# lets make the indexfile from the multifa.seq
use Bio::Index::Fasta;
my $dir = `pwd`;
chomp($dir);
my $tst_index_file = "$dir/t/testIndex.dbm";
unlink($tst_index_file);
my $verbose = 1;
my $ind = Bio::Index::Fasta->new(-filename => $tst_index_file, 
				 -write_flag => 1, 
				 -verbose => $verbose);
$ind->make_index("$dir/t/multifa.seq");
# got to make sure the entire file is synced to disk before proceeeding...

my $server = new Bio::CorbaServer::Server ( -verbose => $verbose,
					    -idl => 'idl/biocorba.idl',
					    -ior => 'seqdbsrv.ior',
					    -orbname=> 'orbit-local-orb');
my $seqdb = $server->new_object(-object=>'Bio::CorbaServer::SeqDB',
				-args => [ '-seqdb' => $ind ]);

$server->start();
