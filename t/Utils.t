# -*-Perl-*-

use strict;

BEGIN {	
    use vars qw($NUMTESTS);
    $NUMTESTS = 40;
    eval { require Test; };
    if( $@ ) { 
	use lib 't';
    }
    use Test;
    plan tests => $NUMTESTS;
    use vars qw($loaded);
}

use Bio::CorbaServer::Utils qw(create_Bioperl_location_from_BSANE_location
			       create_BSANE_location_from_Bioperl_location);
use Bio::Location::Simple;
use Bio::Location::Split;
use Bio::Location::Fuzzy;

$loaded = 1;

END { 
    ok(0) unless $loaded;
}

my $simple = new Bio::Location::Simple('-start' => 2, 
				       '-end' => 13,
				       '-strand' => 1);

my $t1 = create_BSANE_location_from_Bioperl_location($simple);
ok ($t1);
ok ($t1->{'seq_location'}->{'start'}->{'position'}, $simple->start);
ok ($t1->{'seq_location'}->{'start'}->{'extension'}, 0);
ok ($t1->{'seq_location'}->{'start'}->{'fuzzy'}, 1);
ok ($t1->{'seq_location'}->{'end'}->{'position'}, $simple->end);
ok ($t1->{'seq_location'}->{'end'}->{'extension'}, 0);
ok ($t1->{'seq_location'}->{'end'}->{'fuzzy'}, 1);

ok ($t1->{'seq_location'}->{'strand'}, $simple->strand);
ok (scalar @{$t1->{'sub_seq_locations'}},0);
ok ($t1->{'region_operator'}, 0);
$t1 = undef;
my $fuzzy = new Bio::Location::Fuzzy('-start' => "10.14",
				     '-end'   => ">200",
				     '-loc_type' => "..",
				     '-strand'=> -1);

my $t2 = create_BSANE_location_from_Bioperl_location($fuzzy);
ok ($t2);
ok ($t2->{'seq_location'}->{'start'}->{'position'}, $fuzzy->min_start);
ok ($t2->{'seq_location'}->{'start'}->{'extension'}, 4);
ok ($t2->{'seq_location'}->{'start'}->{'fuzzy'}, 2);
ok ($t2->{'seq_location'}->{'end'}->{'position'}, $fuzzy->min_end);
ok ($t2->{'seq_location'}->{'end'}->{'extension'}, 0);
ok ($t2->{'seq_location'}->{'end'}->{'fuzzy'}, 5);

ok ($t2->{'seq_location'}->{'strand'}, $fuzzy->strand);
ok (scalar @{$t2->{'sub_seq_locations'}},0);
ok ($t2->{'region_operator'}, 0);
$t2 = undef;

my $split = new Bio::Location::Split(-splittype => 'join',
				     -locations => [ $simple, $fuzzy ] );

my $t3 = create_BSANE_location_from_Bioperl_location($split);
ok ($t3);
ok ($t3->{'seq_location'}->{'start'}->{'position'}, $simple->start);
ok ($t3->{'seq_location'}->{'start'}->{'extension'}, 0);
ok ($t3->{'seq_location'}->{'start'}->{'fuzzy'}, 1);
ok ($t3->{'seq_location'}->{'end'}->{'position'}, $simple->end);
ok ($t3->{'seq_location'}->{'end'}->{'extension'}, 0);
ok ($t3->{'seq_location'}->{'end'}->{'fuzzy'}, 1);

ok ($t3->{'seq_location'}->{'strand'}, $simple->strand);

ok (@{$t3->{'sub_seq_locations'}},1);
ok ($t3->{'region_operator'}, 1);
($t2) = @{$t3->{'sub_seq_locations'}};

ok ($t2);
ok ($t2->{'seq_location'}->{'start'}->{'position'}, $fuzzy->min_start);
ok ($t2->{'seq_location'}->{'start'}->{'extension'}, 4);
ok ($t2->{'seq_location'}->{'start'}->{'fuzzy'}, 2);
ok ($t2->{'seq_location'}->{'end'}->{'position'}, $fuzzy->min_end);
ok ($t2->{'seq_location'}->{'end'}->{'extension'}, 0);
ok ($t2->{'seq_location'}->{'end'}->{'fuzzy'}, 5);

ok ($t2->{'seq_location'}->{'strand'}, $fuzzy->strand);
ok (scalar @{$t2->{'sub_seq_locations'}},0);
ok ($t2->{'region_operator'}, 0);
