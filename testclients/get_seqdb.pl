#!/usr/local/bin/perl
use strict;
use CORBA::ORBit idl => [ 'idl/biocorba.idl' ];
use Error qw(:try);
my $ior_file = "seqdbsrv.ior";
print STDERR "Got file $ior_file\n";
my $orb = CORBA::ORB_init("orbit-local-orb");

open(F,"$ior_file") || die "Could not open $ior_file";
my $ior = <F>;
chomp $ior;
close(F);


my $db = $orb->string_to_object($ior);
print "db is $db\n";
my $seq;
try {
    my $seq = $db->resolve('AJ235314');
    print "Seq is ", $seq->seq(), "\n";
} catch bsane::IdentifierDoesNotExist with { 
    my $E = shift;
    print "Caught an exception for a nonexistent id - good!\n $E", 
          $E->{'reason'}, "\n";
};

try {
    $seq = $db->resolve('HSEARLOBE');
    print "Seq is ", $seq->seq(), "\n";
    my ($seqs,$iter) = $db->get_seqs(1);
    print "iter is $iter seqs are $seqs\n";
    my ($status,$seq);
    while( (($status, $seq) = $iter->next()) && $status ) {
	print "seq is $seq\n";
	print "seq is ", $seq->get_name(), "\n";
    }
} catch bsane::OutOfBounds with { 
    my $E = shift;
    print "exception is $E", $E->{'reason'}, "\n";
};
