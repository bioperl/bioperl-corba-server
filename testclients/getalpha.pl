#!/usr/bin/perl -w
use strict;
use Error qw(:try);
use CORBA::ORBit idl => [ 'idl/biocorba.idl' ];

my $ior_file = "alphasrv.ior";
print STDERR "Got file $ior_file\n";
my $orb = CORBA::ORB_init("orbit-local-orb");

open(F,"$ior_file") || die "Could not open $ior_file";
my $ior = <F>;
chomp $ior;
close(F);

my $alphabet = $orb->string_to_object($ior);

my $list = $alphabet->get_symbols();
my @amb;

foreach my $s ( @$list ) {
    print "symbol is ", $s->get_name(), "\n";
    push @amb, $s if( $s->get_name eq 'A' ||
		      $s->get_name eq 'C' );    
} 
try {
my $ambiguity = $alphabet->get_ambiguity([@amb]);

print $ambiguity->get_token(), " for symbols A & C\n"; 
} catch bsane::IllegalSymbolException with {
    my $E = shift;
    print "error ", $E->{'reason'}, " $E\n";
}  except {
    print STDERR "exception\n";    
} otherwise {
    print STDERR "Well I don't know what to say\n";
} finally {
    
};

