#!/usr/local/bin/perl -w
use strict;

use Bio::CorbaServer::Server;

# lets make the indexfile from the multifa.seq
use Bio::SeqIO;

my $seqio = new Bio::SeqIO('-format' => 'genbank',
			   '-file' => 't/testfuzzy.genbank');

my $server = new Bio::CorbaServer::Server ( -idl => 'biocorba.idl',
					    -ior => 'fuzzyloc.ior',
					    -orbname=> 'orbit-local-orb');
my $fuzzyseq = $server->new_object(-object=>'Bio::CorbaServer::Seq',
				-args => [ '-seq' => $seqio->next_seq ]);

$server->start();
