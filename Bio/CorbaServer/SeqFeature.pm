# $Id$
#
# BioPerl module for Bio::CorbaServer::SeqFeature
#
# Cared for by Ewan Birney <birney@ebi.ac.uk>
#
# Copyright Ewan Birney
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::CorbaServer::SeqFeature - CORBA wrapper around a SeqFeature 

=head1 SYNOPSIS

See biocorba.idl for methods

=head1 DESCRIPTION

This provides a CORBA wrapping over a SeqFeature object

=head1 FEEDBACK

=head2 Mailing Lists

User feedback is an integral part of the evolution of this and other
Bioperl modules. Send your comments and suggestions preferably to one
of the Bioperl mailing lists.  Your participation is much appreciated.

  bioperl-l@bioperl.org                 - BioPerl discussion
  biocorba-l@biocorba.org               - BioCorba discussion
  http://www.bioperl.org/MailList.html  - About the BioPerl mailing list
  http://www.biocorba.org/MailList.html - About the BioCorba mailing list

=head2 Reporting Bugs

Report bugs to the Bioperl bug tracking system to help us keep track
the bugs and their resolution.  Bug reports can be submitted via email
or the web:

  bioperl-bugs@bio.perl.org
  http://bio.perl.org/bioperl-bugs/

=head1 AUTHOR - Ewan Birney, Jason Stajich

Email birney@ebi.ac.uk
      jason@chg.mc.duke.edu

Describe contact details here

=head1 APPENDIX

The rest of the documentation details each of the object
methods. Internal methods are usually preceded with a _

=cut

# Let the code begin...

package Bio::CorbaServer::SeqFeature;
use vars qw(@ISA %FUZZYCODES);
use strict;
use Bio::CorbaServer::Base;
use Bio::CorbaServer::Iterator;
use Bio::CorbaServer::AnnotationCollection;
use Bio::CorbaServer::Utils qw(create_Bioperl_location_from_BSANE_location
			       create_BSANE_location_from_Bioperl_location);

@ISA = qw(POA_bsane::seqcore::SeqFeature Bio::CorbaServer::Base);

sub new {
    my ($class, @args) = @_;
    my $self = $class->SUPER::new(@args);
    my ($seqf) = $self->_rearrange([qw(SEQFEATURE)], @args);
    if( ! defined $seqf || ! ref $seqf || ! $seqf->isa('Bio::SeqFeatureI') ) {
	die "Must have poa and seq into Seq Feature";
    }
    $self->_seqf($seqf);
    return $self;
}

=head2 bsane::Annotation methods

=head2 get_name

 Title   : get_name
 Usage   : my $name = $annotation->get_name()
 Function: Returns the general type of the annotation
 Returns : string
 Args    : none


=cut

sub get_name{
   my ($self) = @_;
   return $self->_seqf->primary_tag;
}

=head2 get_value

 Title   : get_value
 Usage   : my $value = $annotation->get_value()
 Function: Returns the value for a general annotation
 Returns : string
 Args    : none


=cut

sub get_value{
   my ($self) = @_;
   throw CORBA::NO_IMPLEMENT (-minor => 0x0,
			      -status => 0x0);
}

=head2 get_basis

 Title   : get_basis
 Usage   : my $basis = $annotation->get_basis();
 Function: Returns the basis for an annotation
           valid types are
           NOT_KNOWN=0
           EXPERIMENTAL=1
           COMPUTATIONAL=2
           BOTH=3
           NOT_APPLICABLE=4
 Returns : numeric representing one of the above
 Args    : none

=cut

sub get_basis{
   my ($self) = @_;
   my $tag = $self->_seqf->source_tag;
   if( ! defined $tag || $tag eq '' ) {
       return 0;
   } elsif( $tag =~ /experiment/i ) {
       return 1;
   } elsif( $tag =~ /computation/i ) {
       return 2;
   } elsif( $tag =~ /both/i ) {
       return 3;
   } else { 
       return 4;
   }
}

=head2 bsane::Annotatable methods

=head2 get_annotations

 Title   : get_annotations
 Usage   : my $collection = $annotatable->get_annotations()
 Function: Returns a AnnotationCollection of annotations for this object
 Returns : bsane::AnnotationCollection 
 Args    : none

=cut

sub get_annotations{
   my ($self) = @_;
   my %tags;
   foreach my $tag ( $self->_seqf->all_tags ) {
       $tags{$tag} = [ $self->_seqf->each_tag_value($tag) ];
   }
   my $col = new Bio::CorbaServer::AnnotationCollection('-poa' => $self->poa,
							'-tags' => \%tags);
   return $col->get_activated_object_reference();
}

=head2 base::seqcore::SeqFeature methods

=head2 get_start

 Title   : get_start

 Usage   : my $start  = $obj->get_start 
 Function: starting position of seqfeature 
 Returns : long
 Args    : none

=cut

sub get_start {
  my ($self) = @_;
  $self->_seqf->start;
}

=head2 get_end

 Title   : end
 Usage   : my $end = $obj->get_end
 Function: ending position of seqfeature
 Returns : long
 Args    : none

=cut

sub get_end {
   my ($self) = @_;
   $self->_seqf->end;
}

=head2 get_locations

 Title   : get_locations
 Usage   : my $locations = $seqf->get_locations
 Function: returns SeqFeatureLocationList
 Returns : ref to array of SeqFeatureLocation (hash)
 Args    : none

=cut

sub get_locations {
    my ($self) = @_;
    my $location = $self->_seqf->location();

    if( !defined $location ) {
	throw bsnae::seqcore::UnableToProcess(reason=>'Location object does not exist for contained seqfeature');
    } 

    # recursively build the locations in case they are SplitLocations
    my @locations = &_buildlocations($location);
    my $ref = [];
    push(@$ref,@locations);
	
    return $ref;
}

=head2 get_owner_sequence

 Title   : get_owner_sequence
 Usage   : my $seq = $sf->get_owner_sequence()
 Function: Returns a bsane::seqcore::AnonymousSeq that is the owner of this seq
 Returns : bsane::seqcore::AnonymousSeq (Bio::CorbaServer::PrimarySeq)
 Args    : none


=cut

sub get_owner_sequence{
   my ($self) = @_;
   my $seq;
   if( $self->can('entire_seq') || 
       ! defined ( $seq = $self->_seqf->entire_seq())) {       
       my $s = new Bio::CorbaServer::PrimarySeq('-poa' => $self->poa,
						'-seq' => $seq);
       return $s->get_activated_object_reference();
   } else {
       throw org::biocorba::seqcore::UnableToProcess(reason=>'owner seq is not available') ;
   }
   return undef;
}

# for recursively getting all the locations

sub _buildlocations {
    my ($location) = @_;

    #print STDERR "Building a location with $location\n";

    my @locations;
    if( $location->isa('Bio::Location::SplitLocationI') ) {
	foreach my $loc ( $location->sub_Location() ) {
	    push @locations, &_buildlocations($loc);
	}	
    } else {     
	my($startpos,$endpos);
	my $s = defined $location->start ? $location->start : 
	defined $location->min_start ? $location->min_start :
	    $location->max_start;
	
	my $e = defined $location->end ? $location->end : 
	    defined $location->min_end ? $location->min_end :
		$location->max_end;
	
	my $s_ext = 0;
	if( defined $location->max_start && 
	    defined $location->min_start ) {
	    $s_ext = $location->max_start - $location->min_start;
	}
	
	my $e_ext = 0;
	if( defined $location->max_end && 
	    defined $location->min_end ) {
	    $s_ext = $location->max_end - $location->min_end;
	}	
	
	$startpos = { position => $s,
		      extension => $s_ext,
		      fuzzy => $FUZZYCODES{$location->start_pos_type} };
	
	$endpos = { position => $e,
		    extension => $e_ext,
		    fuzzy => $FUZZYCODES{$location->end_pos_type} };
	 my $h = { 'start' => $startpos,
		   'end'   => $endpos,
		   'strand' => $location->strand };
	push @locations,$h
    }

    #print STDERR "Going to return with ",scalar(@locations),"\n";
    #foreach my $l ( @locations ) {
#	print STDERR "location $l ",$l->{'start'}," ",$l->{'end'},"\n";
#    }

    return @locations;
}

# private methods

sub _recurse_seqf {
    my ($seqf) = @_;
    my (@feats) = $seqf->sub_SeqFeature();
    my @more = @feats;
    foreach my $s ( @feats ) {
	push @more, &_recurse_seqf($s);
    }
    return @more;
}

=head2 _seqf

 Title   : _seqf
 Usage   : $obj->seqf($newval)
 Function: 
 Example : 
 Returns : value of seqf
 Args    : newvalue (optional)


=cut

sub _seqf{
   my ($obj,$value) = @_;
   if( defined $value) {
      $obj->{'_seqf'} = $value;
    }
    return $obj->{'_seqf'};

}
