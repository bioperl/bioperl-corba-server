
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
use Bio::CorbaServer::SeqFeatureCollection;
use Bio::Range;

@ISA = qw(POA_bsane::seqcore::Seq Bio::CorbaServer::PrimarySeq);

# new is handled by PrimarySeq

=head2 get_id

 Title   : get_id
 Usage   :
 Function:
 Example :
 Returns : 
 Args    :


=cut

sub get_id{
   my ($self,@args) = @_;

   return $self->accession_number;
}

=head2 get_name

 Title   : get_name
 Usage   :
 Function:
 Example :
 Returns : 
 Args    :


=cut

sub get_name{
   my ($self) = @_;

   return $self->display_id
}

=head2 get_description

 Title   : get_description
 Usage   :
 Function:
 Example :
 Returns : 
 Args    :


=cut

sub get_description{
   my ($self) = @_;

   return $self->desc;
}



=head2 get_anonymous_sequence

 Title   : get_anonymous_sequence
 Usage   : my $pseq = $seq->get_anonymous_sequence
 Function: returns a primary sequence with no features attached
 Returns : Bio::CorbaServer::PrimarySeq  
 Args    : none
 
This is put here so that clients can ask servers just for the
sequence and then free the large, seqfeature containing sequence.
It prevents a sequence with features having to stay in memory for ever.

=cut

sub get_anonymous_sequence {
    my ($self) = @_;
    my $s =  new Bio::CorbaServer::PrimarySeq('-poa' => $self->poa,
					      '-seq' => $self->_seq->primary_seq);
    return $s->get_activated_object_reference();
}

1;





