#!/usr/bin/perl
use strict;
use CORBA::ORBit idl => [ 'idl/biocorba.idl' ];
use Bio::CorbaServer::Utils qw(create_BSANE_location_from_Bioperl_location);
use Time::HiRes qw(gettimeofday);
use Error qw(:try);
my $ior_file = "seqgetprofile.ior";
print STDERR "Got file $ior_file\n";
my $orb = CORBA::ORB_init("orbit-local-orb");

open(F,"$ior_file") || die "Could not open $ior_file";
my $ior = <F>;
chomp $ior;
close(F);


my $db = $orb->string_to_object($ior);

try {
    my ($seqs,$iter) = $db->get_seqs(1);
    print "iter is $iter seqs are $seqs\n";
    my ($status,$seq);
    while( (($status, $seq) = $iter->next()) && $status ) {
	print "seq is $seq\n";
	print "seq is ", $seq->get_name(), "\n";
	my $sfc = $seq->get_seq_features();
	my $loc = &create_BSANE_location_from_Bioperl_location(new Bio::Location::Simple('-start' => 1, '-end' => $seq->get_length, '-strand' => 1 ) );
	my $start = gettimeofday();
	my $ct =  $sfc->num_features_on_region($loc);
	printf "time to count features = %f\n", gettimeofday() - $start;
	$start = gettimeofday();

	my ($list,$fiter) = $sfc->get_features_on_region(2,&create_BSANE_location_from_Bioperl_location(new Bio::Location::Simple('-start' => 1, '-end' => $seq->get_length-1, '-strand' => 1 ) ));

	printf "time to retrieve features is = %f\n", gettimeofday() - $start;
	$start = gettimeofday();
	my ($fstatus,$feature);
	while( (($fstatus,$feature) = $fiter->next()) && $fstatus ) {
	    print "start is ", $feature->get_start(), " end is ", $feature->get_end(), "\n";
	    my $annotcol = $feature->get_annotations();
	    if( defined $annotcol ) {
		print  "annotation len is ", 
		$annotcol->get_num_annotations(), "\n";
	    } else { 
		print "no annotations returned\n";
	    }
	}
	printf "time to retrieve features is = %f\n", gettimeofday() - $start;
    }

} catch bsane::OutOfBounds with { 
    my $E = shift;
    print "exception is $E", $E->{'reason'}, "\n";
} catch bsane::seqcore::SeqFeatureLocationOutOfBounds with {
    my $E = shift;
    print "exception is $E", $E->{'reason'}, "\n";
};
