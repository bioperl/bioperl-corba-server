
#
# BioPerl module for Bio::CorbaServer::Seq
#
# Cared for by Ewan Birney <birney@ebi.ac.uk>
#
# Copyright Ewan Birney
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::CorbaServer::Seq - CORBA wrapper around a Seq Object

=head1 SYNOPSIS
    
  my $seqio = Bio::SeqIO->new( -format => 'embl' , -file => 'some/file');
  my $seq   = $seqio->next_seq();

  $corbaseq = Bio::CorbaServer::Seq->new($poa,$seq);
  $poa->activate_object($corbaseq);
   # ready to rock and roll.
   
=head1 DESCRIPTION

This provides a CORBA wrapping over a Seq object

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
 the bugs and their resolution.
 Bug reports can be submitted via email or the web:

  bioperl-bugs@bio.perl.org
  http://bio.perl.org/bioperl-bugs/

=head1 AUTHOR - Ewan Birney

Email birney@ebi.ac.uk

Describe contact details here

=head1 APPENDIX

The rest of the documentation details each of the object methods. Internal methods are usually preceded with a _

=cut


# Let the code begin...


package Bio::CorbaServer::Seq;
use vars qw(@ISA);
use strict;

use Bio::CorbaServer::PrimarySeq;
use Bio::CorbaServer::SeqFeature;
use Bio::CorbaServer::SeqFeatureVector;
use Bio::Range;

@ISA = qw(POA_org::biocorba::seqcore::Seq Bio::CorbaServer::PrimarySeq);

# new is handled by PrimarySeq

=head1 Seq functions

These are the key Seq functions

=head2 all_SeqFeatures

 Title   : all_SeqFeatures
 Usage   : my $feats = $obj->all_SeqFeatures(0);
 Function: Return a SeqFeatureVector that allows access to all the
 Example :
 Returns : array of all the features of the sequence
 Args    : boolean whether or not to recurse and include sub feats

=cut

sub all_SeqFeatures {
    my ($self,$recurse) = @_;
    my @sf;

    printf STDERR "Entering all_SeqFeatures...with $recurse\n";

    if( $recurse ) {
	@sf = $self->_seq->all_SeqFeatures();
    } else { 
	@sf = $self->_seq->top_SeqFeatures();
    }
    my $s = new Bio::CorbaServer::SeqFeatureVector('-poa'   => $self->poa,
						   '-items' => \@sf);
    print STDERR "Returning $s with ",scalar(@sf),"\n";
    return $s->get_activated_object_reference();
}

=head2 get_SeqFeatures_by_type

 Title   : get_SeqFeatures_by_type
 Usage   : my $exons = $seq->get_SeqFeatures_by_type(1,'exon');
 Function: obtain seqFeatures that match a particular SeqFeature type
 Returns : seq features of a certain type
 Args    : recurse  - whether or not to recurse into subseq feats
           type     - seqfeature type to get

=cut

sub get_SeqFeatures_by_type {
    my ($self,$recurse,$type) = @_;
    my (@sf,@feats_to_ret);
    if( $recurse ) {
	@sf = $self->_seq->all_SeqFeatures();
    } else { 
	@sf = $self->_seq->top_SeqFeatures();
    }
    foreach my $feat ( @sf ) {
	if( $feat->primary_tag =~ /$type/i ) {
	    push @feats_to_ret,$feat;
	}
    }
    my $s = new Bio::CorbaServer::SeqFeatureVector('-poa'   => $self->poa,
						  '-items' => \@feats_to_ret);
    return $s->get_activated_object_reference();
}

=head2 get_SeqFeatures_in_region

 Title   : get_SeqFeatures_in_region
 Usage   : my $feats = $obj->get_SeqFeatures_in_region(100,200, 0);
 Function:
 Example : retrieves SeqFeatures in a specific region
 Returns : Bio::CorbaServer::SeqFeatureVector
 Args    : start   - starting point or area to search (long)
           end     - ending point of area to search   (long)
           recurse - include sub_seqfeatures? (boolean)
=cut

sub get_SeqFeatures_in_region {
    my ($self, $start,$end,$recurse) = @_;
    if( $start > $self->length || $start <= 0 || 
	$end > $self->length || $end <= 0 || 
	$end < $start) {
	throw  org::biocorba::seqcore::OutOfRange (reason=>"requested region ($start..$end) is not valid for this seq (1..". $self->length.").");	
    }
    my (@sf,@feats_to_ret);
    if( $recurse ) {
	@sf = $self->_seq->all_SeqFeatures();
    } else { 
	@sf = $self->_seq->top_SeqFeatures();
    }
    my $range = new Bio::Range(-start => $start,
			       -end   => $end);
    
    foreach my $feat ( @sf ) {
	if( $range->contains($feat) ) {
	    push @feats_to_ret,$feat;
	}
    }
    my $s = new Bio::CorbaServer::SeqFeatureVector('-poa'   => $self->poa,
						  '-items' => \@feats_to_ret);
    return $s->get_activated_object_reference();
}

=head2 get_SeqFeatures_in_region_by_type

 Title   : get_SeqFeatures_in_region_by_type
 Usage   : my $feats = $obj->get_SeqFeatures_in_region(100,200, 0,'exon');
 Function: retrieve all the seqfeatures in a specific region of a 
           specified type
 Returns : Bio::CorbaServer::SeqFeatureVector
 Args    : start   - starting point or area to search (long)
           end     - ending point of area to search   (long)
           recurse - include sub_seqfeatures? (boolean)
           type    - type of feature to restrict search by
=cut

sub get_SeqFeatures_in_region_by_type {
    my ($self, $start,$end,$recurse,$type) = @_;
    if( $start > $self->length || $start <= 0 || 
	$end > $self->length || $end <= 0 || 
	$end < $start) {
	throw  org::biocorba::seqcore::OutOfRange (reason=>"requested region ($start..$end) is not valid for this seq (1..". $self->length.").");	
    }
    my (@sf,@feats_to_ret);
    if( $recurse ) {
	@sf = $self->_seq->all_SeqFeatures();
    } else { 
	@sf = $self->_seq->top_SeqFeatures();
    }
    my $range = new Bio::Range(-start => $start,
			       -end   => $end);

    foreach my $feat ( @sf ) {
	if( $range->contains($feat) && $feat->primary_tag =~ /$type/i ) {
	    push @feats_to_ret,$feat;
	}
    }
    my $s = new Bio::CorbaServer::SeqFeatureVector('-poa'   => $self->poa,
						   '-items' => \@feats_to_ret);
    return $s->get_activated_object_reference();

}

=head2 get_PrimarySeq

 Title   : get_PrimarySeq
 Usage   : my $pseq = $seq->get_PrimarySeq
 Function: returns a primary sequence with no features attached
 Returns : Bio::CorbaServer::PrimarySeq  
 Args    : none
 
This is put here so that clients can ask servers just for the
sequence and then free the large, seqfeature containing sequence.
It prevents a sequence with features having to stay in memory for ever.

=cut

sub get_PrimarySeq {
    my ($self) = @_;
    my $s =  new Bio::CorbaServer::PrimarySeq('-poa' => $self->poa,
					      '-seq' => $self->_seq->primary_seq);
    return $s->get_activated_object_reference();
}







