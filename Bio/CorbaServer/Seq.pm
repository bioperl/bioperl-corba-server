
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

  $seqio = Bio::SeqIO->new( -format => 'embl' , -file => 'some/file');
  $seq   = $seqio->next_seq();

  $corbaseq = Bio::CorbaServer::Seq->new($poa,$seq);
  $poa->activate_object($corbaseq);
   # ready to rock and roll.


=head1 DESCRIPTION

This provides a CORBA wrapping over a Seq object

=head1 FEEDBACK

=head2 Mailing Lists

User feedback is an integral part of the evolution of this
and other Bioperl modules. Send your comments and suggestions preferably
 to one of the Bioperl mailing lists.
Your participation is much appreciated.

  bioperl-l@bio.perl.org          - General discussion
  bioperl-guts-l@bio.perl.org     - Technically-oriented discussion
  http://bio.perl.org/MailList.html             - About the mailing lists

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
use Bio::CorbaServer::SeqFeatureIterator;

@ISA = qw(POA_org::biocorba::seqcore::Seq Bio::CorbaServer::PrimarySeq);

sub new {
    my ($class, $poa, $seq, @args) = @_;

    my $self = Bio::CorbaServer::PrimarySeq->new($poa, $seq, @args);

    if( ! defined $seq || !ref $seq || ! $seq->isa('Bio::SeqI') ) {
	throw  org::biocorba::seqcore::UnableToProcess (reason=>"Got a non sequence [$seq]");	
    }
    bless $self,$class;
    $self->_seq($seq);
    return $self;
}

=head1 Seq functions

These are the key Seq functions

=head2 all_features

 Title   : all_features
 Usage   :
 Function:
 Example :
 Returns : array of all the features of the sequence
 Args    :

=cut

sub all_features {
    my $self = shift;
    my @sf;
    my @ret;

    @sf = $self->_seq->all_SeqFeatures();

    foreach my $sf ( @sf ) {
	my $serv = Bio::CorbaServer::SeqFeature->new($self->poa,$sf);
	my $id = $self->poa->activate_object ($serv);
	my $temp = $self->poa->id_to_reference ($id);
	push(@ret,$temp);
    }

    return [@ret];
}

sub all_features_iterator {
    my $self = shift;
    my $corbarefs = $self->all_features;

    my $serv = Bio::CorbaServer::SeqFeatureIterator->new($self->poa, 
							 $corbarefs);
    my $id = $self->poa->activate_object($serv);
    my $temp = $self->poa->id_to_reference($id);

    return $temp;
}

=head2 features_region

 Title   : features_region
 Usage   :
 Function:
 Example :
 Returns : features in a specified region
 Args    :

=cut

sub features_region {

}

=head2 features_region_iterator

 Title   : features_region_iterator
 Usage   :
 Function:
 Example :
 Returns : iterator over a region of features for a sequence
 Args    :

=cut

sub features_region_iterator {

}

=head2 get_PrimarySeq

 Title   : get_PrimarySeq
 Usage   :
 Function:
 Example :
 Returns : just a primary sequence with no features attached 
 Args    :
 
This is put here so that clients can ask servers just for the
sequence and then free the large, seqfeature containing sequence.
It prevents a sequence with features having to stay in memory for ever.

=cut

sub get_PrimarySeq {
    my $self = shift;
    my $servant = Bio::CorbaServer::PrimarySeq->new($self->poa,$self->_seq->primary_seq);

   my $id = $self->poa->activate_object ($servant);
   my $temp = $self->poa->id_to_reference ($id);
   return $temp;

}







