#!/usr/local/bin/perl

#$file = shift;
foreach $a (@ARGV) {
    print STDERR "Got argument $a\n";
}

if( ! defined $file ) {
    $file = '/home/birney/src/bioperl-live/t/seqs.fas';
}

use CORBA::ORBit idl => [ 'biocorba.idl' ];

if ( ! defined $file ) {
    die"Must supply bioenv.pl filename (fasta file)\n";
}

$ior_file = "bioenv.ior";
print STDERR "Got file $ior_file\n";
print STDERR "Got input $file\n";

$orb = CORBA::ORB_init("orbit-local-orb");

open(F,"$ior_file") || die "Could not open $ior_file";
$ior = <F>;
chomp $ior;
close(F);

$bioenv = $orb->string_to_object($ior);
print STDERR "Giving fasta [$file]\n";

$seq = $bioenv->PrimarySeq_from_file('fasta',$file);

print "sequence name is ",$seq->display_id,"\n";
print "  seq is",$seq->get_seq(),"\n";

