#!/usr/local/bin/perl -w
use strict;
#$file = shift;
foreach $a (@ARGV) {
    print STDERR "Got argument $a\n";
}
my $file = "t/test_seq.fasta";

use CORBA::ORBit idl => [ 'biocorba.idl' ];

if ( ! defined $file ) {
    die"Must supply bioenv.pl filename (fasta file)\n";
}

my $ior_file = "bioenv.ior";
print STDERR "Got file $ior_file\n";
print STDERR "Got input $file\n";

my $orb = CORBA::ORB_init("orbit-local-orb");

open(F,"$ior_file") || die "Could not open $ior_file";
my $ior = <F>;
chomp $ior;
close(F);

my $bioenv = $orb->string_to_object($ior);
print STDERR "Giving fasta [$file]\n";

my $seq = $bioenv->get_PrimarySeq_from_file('fasta',$file);

print "sequence name is ",$seq->display_id,"\n";
print "  seq is";
print $seq->seq(),"\n";


