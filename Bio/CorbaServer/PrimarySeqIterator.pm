
#
# BioPerl module for Bio::CorbaServer::PrimarySeqIterator
#
# Cared for by Ewan Birney <birney@ebi.ac.uk>
#
# Copyright Ewan Birney
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::CorbaServer::PrimarySeqIterator - CORBA wrapper around a PrimarySeq iterator object

=head1 SYNOPSIS

  $seqio = Bio::SeqIO->new( -format => 'fasta' , -file => 'some/file');
  $iterator = Bio::CorbaServer::PrimarySeqIterator->new ($poa,$seqio);

   $poa->activate_object($iterator);
   # ready to rock and roll.


=head1 DESCRIPTION

This provides a CORBA wrapping over any object which implements the
next_primary_seq method to give back a stream of primary_seq objects.

=head1 FEEDBACK

=head2 Mailing Lists

User feedback is an integral part of the evolution of this
and other Bioperl modules. Send your comments and suggestions preferably
 to one of the Bioperl mailing lists.
Your participation is much appreciated.

  vsns-bcd-perl@lists.uni-bielefeld.de          - General discussion
  vsns-bcd-perl-guts@lists.uni-bielefeld.de     - Technically-oriented discussion
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


package Bio::CorbaServer::PrimarySeqIterator;
use vars qw(@ISA);
use strict;

# Object preamble - inherits from Bio::Root::Object

use Bio::SeqIO;
use Bio::CorbaServer::PrimarySeq;

@ISA = qw(POA_org::Biocorba::Seqcore::PrimarySeqIterator);


sub new {
    my $class = shift;
    my $poa = shift;
    my $seqio = shift;

    my $self = {};

    if( ! defined $seqio ) {
	die "Must have poa and seqio into PrimarySeqIterator";
    }
    bless $self,$class;

    $self->poa($poa);
    $self->seqio($seqio);
    $self->at_end(0);
    $self->_reload();
    return $self;
}

=head2 next

 Title   : next
 Usage   :
 Function:
 Example :
 Returns : 
 Args    :


=cut

sub next{
   my ($self) = @_;
   my $seq;
   if( $self->at_end == 1 ) {
       throw org::Biocorba::Seqcore::EndOfStream;
   }
   $seq= $self->_next_seq();
   $self->_reload();
   my $servant = Bio::CorbaServer::PrimarySeq->new($seq);

   my $id = $self->poa->activate_object ($servant);
   my $temp = $self->poa->id_to_reference ($id);
   return $temp;
}

=head2 has_more

 Title   : has_more
 Usage   :
 Function:
 Example :
 Returns : 
 Args    :


=cut

sub has_more{
   my ($self) = @_;
   
   if($self->at_end == 1 ) {
       return 0;
   } else {
       return 1;
   }

}


=head2 _reload

 Title   : _reload
 Usage   :
 Function:
 Example :
 Returns : 
 Args    :


=cut

sub _reload{
   my ($self) = @_;
   my $seq;

   eval {
       $seq = $self->seqio->next_primary_seq();
   };
   if( $@ || ! defined $seq ) {
       $self->at_end(1);
   } else {
       $self->_next_seq($seq);
   }


}

=head2 _next_seq

 Title   : _next_seq
 Usage   : $obj->_next_seq($newval)
 Function: 
 Example : 
 Returns : value of _next_seq
 Args    : newvalue (optional)


=cut

sub _next_seq{
   my ($obj,$value) = @_;
   if( defined $value) {
      $obj->{'_next_seq'} = $value;
    }
    return $obj->{'_next_seq'};

}



=head2 at_end

 Title   : at_end
 Usage   : $obj->at_end($newval)
 Function: 
 Example : 
 Returns : value of at_end
 Args    : newvalue (optional)


=cut

sub at_end{
   my ($obj,$value) = @_;
   if( defined $value) {
      $obj->{'at_end'} = $value;
    }
    return $obj->{'at_end'};

}

=head2 poa

 Title   : poa
 Usage   : $obj->poa($newval)
 Function: 
 Example : 
 Returns : value of poa
 Args    : newvalue (optional)


=cut

sub poa{
   my ($obj,$value) = @_;
   if( defined $value) {
      $obj->{'poa'} = $value;
    }
    return $obj->{'poa'};

}

=head2 seqio

 Title   : seqio
 Usage   : $obj->seqio($newval)
 Function: 
 Example : 
 Returns : value of seqio
 Args    : newvalue (optional)


=cut

sub seqio{
   my ($obj,$value) = @_;
   if( defined $value) {
      $obj->{'seqio'} = $value;
    }
    return $obj->{'seqio'};

}










