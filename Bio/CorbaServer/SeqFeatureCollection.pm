#
# BioPerl module for Bio::CorbaServer::SeqFeatureCollection
#
# Cared for by Ewan Birney <birney@ebi.ac.uk>
#
# Copyright Ewan Birney
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::CorbaServer::SeqFeatureCollection - A BSANE SeqFeatureCollection - a collection of Collections

=head1 SYNOPSIS

Give standard usage here

=head1 DESCRIPTION

  BSANE SeqFeatureCollection bindings to Sequence

=head1 FEEDBACK

=head2 Mailing Lists

User feedback is an integral part of the evolution of this
and other Bioperl modules. Send your comments and suggestions preferably
 to one of the Bioperl mailing lists.
Your participation is much appreciated.

  bioperl-l@bio.perl.org

=head2 Reporting Bugs

Report bugs to the Bioperl bug tracking system to help us keep track
 the bugs and their resolution.
 Bug reports can be submitted via email or the web:

  bioperl-bugs@bio.perl.org
  http://bio.perl.org/bioperl-bugs/

=head1 AUTHOR - Ewan Birney

Email birney@ebi.ac.uk

Describe contact details here

=head2 CONTRIBUTORS

Jason Stajich, jason@cgt.mc.duke.edu

=head1 APPENDIX

The rest of the documentation details each of the object
methods. Internal methods are usually preceded with a _

=cut


# Let the code begin...


package Bio::CorbaServer::SeqFeatureCollection;
use vars qw(@ISA);
use strict;


use Bio::CorbaServer::Base;
use Bio::CorbaServer::Iterator;
use Bio::CorbaServer::Utils;

@ISA = qw( Bio::CorbaServer::Base POA_bsane::seqcore::SeqFeatureCollection  );
# new() can be inherited from Bio::Root::RootI

sub new {
    my ($class, @args) = @_;
    my $self = $class->SUPER::new(@args);
    my ($seq) = $self->_rearrange([qw(SEQ)],@args);

    if( ! defined $seq || !ref $seq || ! $seq->isa('Bio::PrimarySeqI') ) {
	$seq = '' if( !defined $seq );
	$self->throw($class ." got a non sequence [$seq] for server object");
    }
    $self->_seq($seq);
    return $self;
}


=head2 get_annotations

 Title   : get_annotations
 Usage   : my $feats = $obj->get_annotations();
 Function: 
 Example :
 Returns : array of all the features of the sequence
 Args    : 

=cut

sub get_annotations {
    my ($self,$how_many,$iterator) = @_;
    my @sf;

    @sf = $self->_seq->top_SeqFeatures();

    my @ret = splice(@sf,0,$how_many);

    my @obj;

    foreach my $ret ( @ret ) {
	my $sfobj = new Bio::CorbaServer::SeqFeature( '-poa' => $self->poa,
						      '-seqfeature' => $ret);
	
	push(@obj,$sfobj->get_activated_object_reference);
    }

    my $it = new Bio::CorbaServer::Iterator('-poa'   => $self->poa,
					    '-items' => \@sf);
    $iterator = $it->get_activated_object_reference();
    return @obj;
}

=head2 get_features_on_region

 Title   : get_features_on_region
 Usage   : 
 Function:
 Example :
 Returns : Array of features in a region 
 Args    : int how_many       -- maximum number of features to return
           SeqFeatureLocation -- SeqFeatureLocation to search
           the_rest           -- The remaining elements (more than how_many
				 are available from this iterator)

=cut

sub get_features_on_region {
   my ($self,$how_many, $seq_region, $the_rest) = @_;
   if( ! $seq_region || ! ref($seq_region) ) {
       throw bsane::seqcore::UnableToProcess
	   ( reason => ref($self). " get_features_on_region got invalid seq_region parameter (".ref($seq_region).")");	
   }
   my $seq = $self->_seq;
   my $seq_region_location = &create_location_from_BSANE_Location($seq_region); 
   if( $seq->length < $seq_region_location->start ||
       $seq_region_location->end ) {
       throw bsane::seqcore::SeqFeatureLocationOutOfBounds
	   (
	    $seq_region,
	    &create_BSANE_location_from_Bioperl_location(new Bio::Location::Simple('-start' => 1, '-end' => $seq->length, '-strand' => 0 ) )
	    );
   }
   my @features;
   foreach my $feature ( $seq->top_SeqFeatures() ) {
       if( $feature->overlaps( $seq_region_location ) ) {
	   push @features, $feature;
       }
   }
   
   my @obj;
   foreach my $f ( @features ) {
       my $sfobj = new Bio::CorbaServer::SeqFeature( '-poa' => $self->poa,
						     '-seqfeature' => $f);
       push @obj, $sfobj; 
   }
   @features = ();
   my @ret = splice(@obj,0,$how_many);
   foreach my $r ( @ret ) {
       push @features, $r->get_actived_object_reference;
   }

   my $it = new Bio::CorbaServer::Iterator('-poa'   => $self->poa,
					   '-items' => \@obj);
   $the_rest = $it->get_activated_object_reference();   
   return @ret;
}

=head2 num_features_on_region

 Title   : num_features_on_region
 Usage   : my $count = $seqfeatcol->num_features_on_region($searchregion);
 Function: Returns the number of sequence features in a give sequence region
 Returns : integer
 Args    : bsane::seqcore::SeqFeatureLocation

=cut

sub num_features_on_region { 
    my ($self, $seq_region) = @_;
   my $seq = $self->_seq;
   my $seq_region_location = &create_location_from_BSANE_Location($seq_region); 
   if( $seq->length < $seq_region_location->start ||
       $seq_region_location->end ) {
       throw bsane::seqcore::SeqFeatureLocationOutOfBounds
	   (
	    $seq_region,
	    &create_BSANE_location_from_Bioperl_location(new Bio::Location::Simple('-start' => 1, '-end' => $seq->length, '-strand' => 0 ) )
	    );
   }
    my $count = 0;
    foreach my $feature ( $seq->top_SeqFeatures() ) {
	$count++ if( $feature->overlaps( $seq_region_location ));
    }
    return $count;
}

=head1 Private Methods

Private Methods local to this module

=head1 _seq

 Title   : _seq
 Usage   : get/set seq reference
 Function:
 Example : $self->_seq($new_seq)
 Returns : reference to underlying contained seq object
 Args    : [optional] new-value

=cut

sub _seq {
    my ($self,$value) = @_;
    if( defined $value) {	
	$self->{'_seqobj'} = $value;
    }
    return $self->{'_seqobj'};
}


1;

