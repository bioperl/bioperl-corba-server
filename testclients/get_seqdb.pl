#!/usr/local/bin/perl
use strict;
use Data::Dumper;
use CORBA::ORBit idl => [ 'idl/biocorba.idl' ];
use Bio::CorbaServer::Utils qw(create_BSANE_location_from_Bioperl_location);

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
    $seq = $db->resolve('HUMBDNF');
    print "Seq is ", $seq->seq(), "\n";
    my ($seqs,$iter) = $db->get_seqs(1);
    print "iter is $iter seqs are $seqs\n";
    my ($status,$seq);
    while( (($status, $seq) = $iter->next()) && $status ) {
	print "seq is $seq\n";
	print "seq is ", $seq->get_name(), "\n";
	my $sfc = $seq->get_seq_features();
	my $loc = &create_BSANE_location_from_Bioperl_location(new Bio::Location::Simple('-start' => 1, '-end' => $seq->get_length, '-strand' => 1 ) );
	#print "loc is ", Dumper($loc),"\n";
	print "feature count is ", $sfc->num_features_on_region($loc),"\n";

	my ($list,$iter) = $sfc->get_features_on_region(2,&create_BSANE_location_from_Bioperl_location(new Bio::Location::Simple('-start' => 1, '-end' => $seq->get_length-1, '-strand' => 1 ) ));
    }
    my ($seqs,$iter) = $db->get_seqs(1);
    print "iter is $iter seqs are $seqs\n";

    while( (($status, $seq) = $iter->next_n(2)) && $status ) {
	print "status is $status\n";
	foreach my $s ( @$seq ) {
	    print "seq is $s\n";
	}
    }
    
    

} catch bsane::OutOfBounds with { 
    my $E = shift;
    print "exception is $E", $E->{'reason'}, "\n";
} catch bsane::seqcore::SeqFeatureLocationOutOfBounds with {
    my $E = shift;
    print "exception is $E", $E->{'reason'}, "\n";
};
