#!/usr/local/bin/perl -w

=head1 NAME

biosql_srv.pl - Access to BioSQL srv.

=head1 SYNOPSIS

   load_seqdatabase.pl -host somewhere.edu -sqldb bioperl swiss_sptrembl 

=head1 DESCRIPTION

This script provides a test example of wrapping biocorba client around
biosql-db . There are a number of options to do with where the
bioperl-db database is (ie, hostname, user for database, password,
database name) followed by the database name.

=cut


use strict;
BEGIN {
    eval { 
	require Bio::DB::SQL::DBAdaptor;
    };
    if( $@ ) {
	die("must have bioperl-db library installed and in your PERL5LIB");
    }
}

use Bio::CorbaServer::Server;
use Bio::DB::SQL::DBAdaptor;
use Getopt::Long;
use Bio::SeqIO;

my $host = "localhost";
my $sqlname = "bioperl_db";
my $dbuser = "root";
my $dbpass = undef;
#If safe is turned on, the script doesn't die because of one bad entry..
my $safe = 0;

&GetOptions( 'host:s' => \$host,
             'sqldb:s'  => \$sqlname,
             'dbuser:s' => \$dbuser,
             'dbpass:s' => \$dbpass,
             'safe'     => \$safe
             );

my $dbname = shift;

if( !defined $dbname ) {
    system("perldoc $0");
    exit(0);
}

my $dbadaptor = Bio::DB::SQL::DBAdaptor->new( -host => $host,
					      -dbname => $sqlname,
					      -user => $dbuser,
					      -pass => $dbpass
					      );

my $seqdb = $dbadaptor->get_BioDatabaseAdaptor->fetch_BioSeqDatabase_by_name($dbname);

my $server = new Bio::CorbaServer::Server ( -idl => 'idl/biocorba.idl',
					    -ior => 'sqldbsrv.ior',
					    -orbname=> 'orbit-local-orb');
my $serverobj = $server->new_object(-object=>'Bio::CorbaServer::SeqDB',
				    -args => [ '-seqdb', $seqdb ]);

print "starting SQL server wrapper\n";

$server->start();

END {
    unlink 'sqldbsrv.ior';
}
