#!/usr/local/lib/perl

use Bio::CorbaServer::Server;

# lets make the indexfile from the multifa.seq
use Bio::Symbol::DNAAlphabet;

my $alphabet = new Bio::Symbol::DNAAlphabet();
my $verbose = 1;
my $server = new Bio::CorbaServer::Server ( -verbose => $verbose,
					    -idl => 'idl/biocorba.idl',
					    -ior => 'alphasrv.ior',
					    -orbname=> 'orbit-local-orb');

my $alpha = $server->new_object(-object=>'Bio::CorbaServer::Alphabet',
				-args => [ '-alphabet' => $alphabet ]);

$server->start();
