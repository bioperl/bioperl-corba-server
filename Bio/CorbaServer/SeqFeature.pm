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
use Bio::CorbaServer::SeqFeatureVector;

@ISA = qw(POA_org::biocorba::seqcore::SeqFeature Bio::CorbaServer::Base);

BEGIN { 
    %FUZZYCODES = ( 'EXACT' => 1,
		    'WITHIN' => 2,
		    'BETWEEN' => 3,
		    'BEFORE' => 4,
		    'AFTER'  => 5 );
}
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

=head2 type

 Title   : type
 Usage   : my $type = $sf->type;
 Function: return the type of seqfeature ie 'exon'
 Returns : string
 Args    : none


=cut

sub type{
   my ($self) = @_;
   return $self->_seqf->primary_tag;
}

=head2 source

 Title   : source
 Usage   : my $src = $sf->source;
 Function: return the source of the seqfeature (GFF compatibility)
 Returns : string
 Args    : none


=cut

sub source {
  my ($self) = @_;
  return $self->_seqf->source_tag;
}


=head2 seq_primary_id

 Title   : seq_primary_id
 Usage   : my $Id  = $sf->seq_primary_id;
 Function: returns the primary id of seq that seqfeature belongs to
 Example :
 Returns : seq_id of the 
 Args    : 

=cut

sub seq_primary_id {
  my ($self) = @_;
  return $self->_seqf->location->seq_id || -1;
}

=head2 start

 Title   : start
 Usage   : my $start  = $obj->start 
 Function: starting position of seqfeature 
 Returns : long
 Args    : none

=cut

sub start {
  my ($self) = @_;
  $self->_seqf->start;
}

=head2 end

 Title   : end
 Usage   : my $end = $obj->end
 Function: ending position of seqfeature
 Returns : long
 Args    : none

=cut

sub end {
   my ($self) = @_;
   $self->_seqf->end;
}

=head2 strand

 Title   : strand
 Usage   : my $strand = $obj->strand 
 Function: returns strand seqfeature is on
 Returns : short (-1,0,1) 0 for protein
 Args    : none


=cut

sub strand{
   my ($self) = @_;
   return $self->_seqf->strand;
}

=head2 qualifiers

 Title   : qualifiers
 Usage   : my @qual = $obj->qualifiers
 Function: returns properties
 Returns : array ref to list of hashes 
 Args    :

=cut

sub qualifiers{
  my ($self,@args) = @_;
  my @tags = $self->_seqf->all_tags;

  my @all_values;
  foreach my $tag (@tags) {
    my $name_value = { name => $tag,
		       values =>[$self->_seqf->each_tag_value($tag)]
		     };
    push(@all_values, $name_value);
  }
      
  return [@all_values];
}
=head2 sub_SeqFeatures

 Title   : sub_SeqFeatures
 Usage   : my $featvector = $obj->sub_SeqFeatures();
 Function: return a SeqFeatureVector containing all sub features 
 Returns : Bio::CorbaServer::SeqFeatureVector
 Args    : boolean (search recursively)

=cut

sub sub_SeqFeatures {
    my($self, $recurse) = @_;
        
    my @subfeatures;
    if( $recurse ) {
	@subfeatures = &_recurse_seqf($self->_seqf);
    } else { 
	@subfeatures = $self->_seqf->sub_SeqFeature();
    }

    my @final;
    foreach my $subf ( @subfeatures ) {
	my $sf = new Bio::CorbaServer::SeqFeature('-poa' => $self->poa,
						  '-seqfeature' => $subf);
	push @final, $sf;
    }
    my $s = new Bio::CorbaServer::SeqFeatureVector('-poa' => $self->poa,
						   '-elements' => \@final);
    return $s->get_activated_object_reference();
}

=head2 locations

 Title   : locations
 Usage   : my $locations = $seqf->SeqFeatureLocationList
 Function: returns if PrimarySeq is available (and attached)
 Returns : ref to array of SeqFeatureLocation (hash)
 Args    : none

=cut

sub locations {
    my ($self) = @_;
    my $location = $self->_seqf->location();
    my @locations;

    if( !defined $location ) {
	throw org::biocorba::seqcore::UnableToProcess(reason=>'Location object does not exist for contained seqfeature');
    } 

    # recursively build the locations in case they are SplitLocations
    my @locations = &_buildlocations($location);
    my $ref = [];
    push(@$ref,@locations);
	
    return $ref;
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

=head2 PrimarySeq_is_available

 Title   : PrimarySeq_is_available
 Usage   : if( $seqf->PrimarySeq_is_available) { ... }
 Function: returns if PrimarySeq is available (and attached)
 Returns : boolean
 Args    : none

=cut

sub PrimarySeq_is_available{
   my ($self) = @_;
   if( $self->can('seq') ) {
       return ( defined $self->_seqf->seq() );
   }
   return 0;
}

=head2 get_PrimarySeq

 Title   : get_PrimarySeq
 Usage   : my $pseq = $seqf->get_PrimarySeq();
 Function: returns the primary sequence for this SeqFeature
 Returns : Bio::CorbaServer::PrimarySeq
 Args    : none

=cut

sub get_PrimarySeq{
   my ($self) = @_;
   if( $self->PrimarySeq_is_available ) {
       my $s = new Bio::CorbaServer::PrimarySeq('-poa' => $self->poa,
					       '-seq' => $self->_seqf->seq());
       return $s->get_activated_object_reference();
   } else {
       throw org::biocorba::seqcore::UnableToProcess(reason=>'PrimarySeq is not available') ;
   }
   return undef;
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
