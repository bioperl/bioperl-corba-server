#!/usr/local/bin/perl -w
use strict;

use Bio::CorbaServer::Server;

# lets make the indexfile from the multifa.seq
use Bio::Index::Fasta;
my $dir = `pwd`;
chomp($dir);
my $tst_index_file = "$dir/t/testIndex.dbm";
unlink($tst_index_file);
my $ind = Bio::Index::Fasta->new(-filename => $tst_index_file, 
				 -write_flag => 1, 
				 -verbose => 1);
$ind->make_index("$dir/t/multifa.seq");
# got to make sure the entire file is synced to disk before proceeeding...
$ind = undef;

my $seqdbindex = Bio::Index::Fasta->new(-filename => $tst_index_file, 
				 -write_flag => 0, 
				 -verbose => 1);

my $server = new Bio::CorbaServer::Server ( -idl => 'biocorba.idl',
					    -ior => 'seqdbsrv.ior',
					    -orbname=> 'orbit-local-orb');
my $seqdb = $server->new_object(-object=>'Bio::CorbaServer::SeqDB',
				-args => [ '-name' => 'testdb', 
					   '-seqdb' => $seqdbindex ]);

$server->start();
