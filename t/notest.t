## Bioperl Test Harness Script for Modules
##


# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.t'

#-----------------------------------------------------------------------
## perl test harness expects the following output syntax only!
## 1..3
## ok 1  [not ok 1 (if test fails)]
## 2..3
## ok 2  [not ok 2 (if test fails)]
## 3..3
## ok 3  [not ok 3 (if test fails)]
##
## etc. etc. etc. (continue on for each tested function in the .t file)
#-----------------------------------------------------------------------


## We start with some black magic to print on failure.
BEGIN { $| = 1; print "1..1\n"; 
	use vars qw($loaded); }

END {print "not ok 1\n" unless $loaded;}

use CORBA::ORBit idl => [ 'biocorba.idl' ];
use Bio::CorbaServer::Seq;
use Bio::CorbaServer::PrimarySeq;
use Bio::CorbaServer::PrimarySeqIterator;
use Bio::CorbaServer::PrimarySeqDB;
use Bio::CorbaServer::SeqDB;
use Bio::CorbaServer::SeqFeature;
use Bio::CorbaServer::SeqFeatureIterator;
use Bio::CorbaServer::BioEnv;


print STDERR "\n\tuse the servers and testclients to actually test this code\n";
print "ok 1";
