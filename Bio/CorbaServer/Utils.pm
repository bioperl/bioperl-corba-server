# $Id$
#
# BioPerl module for Bio::CorbaServer::Utils
#
# Cared for by Jason Stajich <jason@bioperl.org>
#
# Copyright Jason Stajich
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::CorbaServer::Utils - Utilities for converting BSANE structs to
bioperl objects

=head1 SYNOPSIS

Give standard usage here

=head1 DESCRIPTION

Describe the object here

=head1 FEEDBACK

=head2 Mailing Lists

User feedback is an integral part of the evolution of this and other
Bioperl modules. Send your comments and suggestions preferably to
the Bioperl mailing list.  Your participation is much appreciated.

  bioperl-l@bioperl.org            - General discussion
http://bioperl.org/MailList.shtml  - About the mailing lists

=head2 Reporting Bugs

Report bugs to the Bioperl bug tracking system to help us keep track
of the bugs and their resolution. Bug reports can be submitted via
email or the web:

  bioperl-bugs@bioperl.org
  http://bioperl.org/bioperl-bugs/

=head1 AUTHOR - Jason Stajich

Email jason@bioperl.org

Describe contact details here

=head1 APPENDIX

The rest of the documentation details each of the object methods.
Internal methods are usually preceded with a _

=cut


# Let the code begin...


package Bio::CorbaServer::Utils;
use strict;
use vars qw(@ISA @EXPORT_OK @EXPORT);

use Exporter;
use Bio::Location::Simple;
use Bio::Location::Fuzzy;
use Bio::Location::Split;
@ISA = qw(Exporter);
             # functions
@EXPORT_OK = qw(create_Bioperl_location_from_BSANE_location		
		create_BSANE_location_from_Bioperl_location
		%StrandType %SeqType %FuzzyType %SeqFeatureLocationOperator);
BEGIN { 

    use vars qw( %StrandType %SeqType %FuzzyType %SeqFeatureLocationOperator);
# codes from seqcore.idl
    %StrandType = ( 'NOT_KNOWN'      => 3,
		    'NOT_APPLICABLE' => 2,
		    'PLUS'           => 1,
		    'MINUS'          => -1,
		    'BOTH'           => 0 );

    %SeqType = ( 'PROTEIN'   => 0,
		 'DNA'       => 1,
		 'RNA'       => 2,
		 'NOT_KNOWN' => -1,
		 );

    %FuzzyType = ( 'EXACT'  => 1,
		   'WITHIN' => 2,
		   'BETWEEN'=> 3,
		   'BEFORE' => 4,
		   'AFTER'  => 5);

    %SeqFeatureLocationOperator  = ( 'NONE' => 0,
				     'JOIN' => 1,
				     'ORDER'=> 2);
# allow reverse lookup
    foreach my $hash ( \%StrandType, \%SeqType, \%FuzzyType, 
		       \%SeqFeatureLocationOperator ) {
	my @fields = keys %{$hash};
	foreach my $field ( @fields ) {
	    $hash->{$hash->{$field}} = $field;
	}
    }  
}

=head2 create_Bioperl_location_from_BSANE_location

 Title   : create_Bioperl_location_from_BSANE_location
 Usage   : create_Bioperl_location_from_BSANE_location($hashref)
 Function: Creates a Bio::LocationI from a BSANE hashref SeqFeature location
 Returns : Bio::LocationI
 Args    : BSANE hashref SeqFeature location

=cut

sub create_Bioperl_location_from_BSANE_location {
    my ($bsaneloc) = @_;

    my $type = 'Bio::Location::Simple'; # default type of locations
    my @args;

    # WHAT ABOUT STRAND and EXTENSION -- DONE

    foreach my $pl ( qw(start end) ) {
	my $p = $bsaneloc->{'seq_location'}->{$pl};
	push @args, 
	( "-$pl" => $p->{'position'},
	  "-$pl\_ext" => $p->{'extension'},# if this is zero no worries
	  "-$pl\_fuz" => $p->{'fuzzy'},	   # if this is 1 or 'EXACT' no worries
	  "-strand"   => $p->{'strand'},
	  );
	if( $p->{'fuzzy'} > 1 || $p->{'extension'} > 0 ) {
	    $type = 'Bio::Location::Fuzzy';
	}
    }

    my $location = $type->new(@args);
    if( $bsaneloc->{'region_operator'} > 0 ) { # if it is not A NONE  
	my $sloc = new Bio::Location::Split
	    ('-splittype' => $SeqFeatureLocationOperator{$bsaneloc->{'region_operator'}},
	     '-locations' => [ $location ] );
	$location = $sloc;
	foreach my $subloc ( @{$bsaneloc->{'sub_Seq_locations'}} ) {
	    $location->add_sub_Location(&create_location_from_BSANE_Location($subloc));
	}
    }
    return $location;
}

=head2 create_BSANE_location_from_Bioperl_location

 Title   : create_BSANE_location_from_Bioperl_location
 Usage   : create_BSANE_location_from_Bioperl_location(Bio::LocationI)
 Function: Creates a BSANE suitable SeqFeature hashref from 
           a Bioperl Location object 
 Returns : Reference to a hash suitable for BSANE Corba server
 Args    : Bio::LocationI

=cut

sub create_BSANE_location_from_Bioperl_location { 
    my ($location) = @_;
    return undef if( ! $location );
    my $splittype = $SeqFeatureLocationOperator{'NONE'};
    my $locations = [];

    if( $location->isa('Bio::Location::SplitLocationI') ) {
	my @a = $location->sub_Location;
	$locations = \@a;
	my $first = shift @$locations;
	$splittype  = $SeqFeatureLocationOperator{$location->splittype};
	foreach my $loc ( @$locations ) {
	    # reset $loc to BSANE loc - is a ref so we can update in place
	    $loc = &create_BSANE_location_from_Bioperl_location($loc);
	}
	# location is really the first loc
	$location = $first;
    }
    my $s_ext = 0;
    my $e_ext = 0;
    my $s_fuzzy = $FuzzyType{'EXACT'};   
    my $e_fuzzy = $FuzzyType{'EXACT'};   

    if( $location->max_start && $location->min_start ) {
	$s_ext = $location->max_start - $location->min_start;
    } else {  $s_ext = 0; }
    if( $location->max_end && $location->min_end ) {
	$e_ext = $location->max_end - $location->min_end;
    } else {  $e_ext = 0; }
    
    $s_fuzzy = $FuzzyType{$location->start_pos_type};	
    $e_fuzzy = $FuzzyType{$location->end_pos_type};
    
    return { 'seq_location' => 
		 { 
		     'start' => { 
			 'position'  => $location->min_start,
			 'extension' => $s_ext,
			 'fuzzy'     => $s_fuzzy,
		     },
		     'end'   => { 
			 'position'  => $location->min_end,
			 'extension' => $e_ext,
			 'fuzzy'     => $e_fuzzy,
		     },
		     'strand' => $location->strand, 
		 },
		 'region_operator'   => $splittype,
		 'sub_seq_locations' => $locations,
		 'id'                => undef,
	 };
}


1;
