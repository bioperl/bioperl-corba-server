# $Id$
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
use Bio::CorbaServer::Base;
use Bio::CorbaServer::SeqFeatureCollection;
use Bio::CorbaServer::AnnotationCollection;
use Bio::CorbaServer::Alphabet;
use Bio::Symbol::DNAAlphabet;
use Bio::Symbol::ProteinAlphabet;

@ISA = qw( POA_bsane::seqcore::BioSequence Bio::CorbaServer::PrimarySeq  );

=head2 BioSequence methods

=head2 get_anonymous_sequence

 Title   : get_anonymous_sequence
 Usage   : my $seq = $obj->get_anonymouse_sequence();
 Function: Returns an anonymous sequence for a BioSequence
 Returns : seqcore::AnonymouseSequence
 Args    : none

=cut

sub get_anonymous_sequence{
   my ($self,@args) = @_;
   my $s = new Bio::CorbaServer::PrimarySeq('-poa' => $self->poa,
					     '-seq' => $self->_seq);
   return $s->get_activated_object_reference;
}

=head2 get_seq_features

 Title   : get_seq_features
 Usage   : $collection = $seq->get_seq_features()
 Function: Get a SeqFeatureCollection
 Returns : bsane::seqcore::SeqFeatureCollection
 Args    : none

=cut

sub get_seq_features{
    my ($self) = @_;
    my $sfc = new Bio::CorbaServer::SeqFeatureCollection('-poa' => $self->poa,
							 '-seq' => $self->_seq);
    return $sfc->get_activated_object_reference;
}

=head2 get_annotations

 Title   : get_annotations
 Usage   : $collection = $seq->get_annotations
 Function: Get an AnnotationCollection
 Returns : bsane::AnnotationCollection
 Args    : none

=cut

sub get_annotations {
    my ($self) = @_;
    my $anc = new Bio::CorbaServer::AnnotationCollection
	('-poa' => $self->poa,
	 '-collection' => $self->_seq->annotation);
    return $anc->get_activated_object_reference;
}

=head2 get_alphabet

 Title   : get_alphabet
 Usage   : my $alphabet = $obj->get_alphabet();
 Function: Retrieves the alphabet for this sequence
 Returns : bsane::Alphabet 
 Args    : none

=cut

sub get_alphabet{
   my ($self,@args) = @_;
   my $alphabet;
   if( $self->_seq->alphabet eq 'dna' ) {
       $alphabet = new Bio::Symbol::DNAAlphabet();

   } elsif( $self->_seq->alphabet eq 'protein' ) {
       $a = new Bio::Bio::Symbol::ProteinAlphabet();
   } else {
       throw bsane::IllegalSymbolException('reason' => 'Alphabet type '. $self->_seq->alphabet . ' is unknown');
   }
   my $a = new Bio::CorbaServer::Alphabet('-alphabet' => $alphabet,
					  '-poa'      => $self->poa);
   return $a->get_activated_object_reference;
}

1;
