#!/usr/local/bin/perl -w
use strict;
use CORBA::ORBit idl => [ 'biocorba.idl' ];
use Error qw(:try);
my $ior_file = "seqfeatures.ior";
print STDERR "Got file $ior_file\n";
my $orb = CORBA::ORB_init("orbit-local-orb");

open(F,"$ior_file") || die "Could not open $ior_file";
my $ior = <F>;
chomp $ior;
close(F);

my $seq = $orb->string_to_object($ior);

my $vector = $seq->all_SeqFeatures(1);

my $iter = $vector->iterator();
print "All\n---------\n";
while ( $iter->has_more ) {
    my $sf = $iter->next();
    print "\t type is ", $sf->type(),
    " source is ", $sf->source, "\nstart=", $sf->start,
    ", end=", $sf->end, ", strand=", $sf->strand, "\n";
}

print "-----------\nThose 20 < X < 850\n---------\n";

$vector = $seq->get_SeqFeatures_in_region(20,850, 0);

$iter = $vector->iterator();
    
while ( $iter->has_more ) {
    my $sf = $iter->next();
    print "\t type is ", $sf->type(),
    " source is ", $sf->source, "\nstart=", $sf->start,
    ", end=", $sf->end, ", strand=", $sf->strand, "\n";
}

print "-----------\nThose of type 'gene'\n---------\n";

$vector = $seq->get_SeqFeatures_by_type(0, 'GENE');

$iter = $vector->iterator();
    
while ( $iter->has_more ) {
    my $sf = $iter->next();
    print "\t type is ", $sf->type(),
    " source is ", $sf->source, "\nstart=", $sf->start,
    ", end=", $sf->end, ", strand=", $sf->strand, "\n";
}

print "-----------\nThose of type 'gene' and in 20 < X < 817\n---------\n";

$vector = $seq->get_SeqFeatures_in_region_by_type(20,817, 0,'GENE');

$iter = $vector->iterator();
    
while ( $iter->has_more ) {
    my $sf = $iter->next();
    print "\t type is ", $sf->type(),
    " source is ", $sf->source, "\nstart=", $sf->start,
    ", end=", $sf->end, ", strand=", $sf->strand, "\n";
}

# test error handling
try {
   $seq->get_SeqFeatures_in_region_by_type(0,3000, 0,'GENE');
} catch org::biocorba::seqcore::OutOfRange with {    
    my $E = shift;
    print "Caught: ", $E->{'reason'}, "\n";
};

try {
    $seq->get_SeqFeatures_in_region_by_type(0,3000, 0,'GENE');
} catch org::biocorba::seqcore::OutOfRange with {
    my $E = shift;
    print "Caught: ", $E->{'reason'}, "\n";
};

try {
    $seq->get_SeqFeatures_in_region(1000,1001, 0);
} catch org::biocorba::seqcore::OutOfRange with {
    my $E = shift;
    print "Caught: ", $E->{'reason'}, "\n";
};

try { 
    $seq->get_SeqFeatures_in_region(1001,800, 0);
} catch org::biocorba::seqcore::OutOfRange with {
    my $E = shift;
    print "Caught: ", $E->{'reason'}, "\n";
};

try {
    $seq->get_SeqFeatures_in_region(800,100, 0);
}
catch org::biocorba::seqcore::OutOfRange with {
    my $E = shift;
    print "Caught: ", $E->{'reason'}, "\n";
};

