## Bioperl Test Harness Script for Modules
##

# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.t'

use Test;
use strict;
BEGIN { plan tests => 10 }

use CORBA::ORBit idl => [ 'biocorba.idl' ];
use Bio::CorbaServer::AnonymousSeq;
ok(1);
use Bio::CorbaServer::Seq;
ok(1);
use Bio::CorbaServer::PrimarySeq;
ok(1);
use Bio::CorbaServer::PrimarySeqVector;
ok(1);
use Bio::CorbaServer::PrimarySeqIterator;
ok(1);
use Bio::CorbaServer::PrimarySeqDB;
ok(1);
use Bio::CorbaServer::SeqDB;
ok(1);
use Bio::CorbaServer::SeqFeature;
ok(1);
use Bio::CorbaServer::SeqFeatureIterator;
ok(1);
use Bio::CorbaServer::BioEnv;
ok(1);
print STDERR "\tuse the servers and testclients to actually test this code\n";
