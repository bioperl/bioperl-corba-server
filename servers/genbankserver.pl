#!/usr/local/bin/perl -w
use strict;

use Bio::CorbaServer::Server;

# lets make the indexfile from the multifa.seq
use Bio::Index::GenBank;
my $tst_index_file = "/tmp/gbmam.dbm";
my $ind = Bio::Index::GenBank->new($tst_index_file, 
				 'WRITE');
$ind->make_index("/tmp/gbmam.seq");
# got to make sure the entire file is synced to disk before proceeeding...
$ind = undef;

my $seqdbindex = Bio::Index::GenBank->new($tst_index_file);

my $server = new Bio::CorbaServer::Server ( -idl => 'biocorba.idl',
					    -ior => 'seqdbsrv.ior',
					    -orbname=> 'orbit-local-orb');
my $seqdb = $server->new_object(-object=>'Bio::CorbaServer::SeqDB',
				-args => [ 'GenBank Mamalian', $seqdbindex ]);

$server->start();
