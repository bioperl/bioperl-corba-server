#!/usr/local/bin/perl

use CORBA::ORBit idl => [ 'idl/biocorba.idl' ];
use Error qw(:try);
$ior_file = "seqdbsrv.ior";
print STDERR "Got file $ior_file\n";
$orb = CORBA::ORB_init("orbit-local-orb");

open(F,"$ior_file") || die "Could not open $ior_file";
$ior = <F>;
chomp $ior;
close(F);


my $db = $orb->string_to_object($ior);
print "db is $db\n";
try {
    my $seq = $db->resolve('AJ235314');
    print "Seq is ", $seq->seq(), "\n";
} except { 
    my $E = shift;
    print "exception $E", $E->{'reason'}, "\n";
};
