
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


=head1 DESCRIPTION

This provides a CORBA wrapping over a SeqFeature object

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


package Bio::CorbaServer::SeqFeature;
use vars qw(@ISA);
use strict;



@ISA = qw(POA_org::Biocorba::Seqcore::SeqFeature);


sub new {
    my $class = shift;
    my $poa = shift;
    my $seqf = shift;

    my $self = {};

    if( ! defined $seq ) {
	die "Must have poa and seq into Seq";
    }
    bless $self,$class;

    $self->poa($poa);
    $self->seqf($seqf);
    return $self;
}

=head2 type

 Title   : type
 Usage   :
 Function:
 Example :
 Returns : 
 Args    :


=cut

sub type{
   my ($self,@args) = @_;

   return $self->seqf->primary_tag;
}

=head2 source

 Title   : source
 Usage   :
 Function:
 Example :
 Returns : 
 Args    :


=cut

sub source{
   my ($self,@args) = @_;

   return $self->seqf->source_tag;
}

=head2 start

 Title   : start
 Usage   :
 Function:
 Example :
 Returns : 
 Args    :


=cut

sub start{
   my ($self,@args) = @_;
   
   $self->seqf->start;
}

=head2 end

 Title   : end
 Usage   :
 Function:
 Example :
 Returns : 
 Args    :


=cut

sub end{
   my ($self,@args) = @_;

   $self->seqf->end;
}

=head2 strand

 Title   : strand
 Usage   :
 Function:
 Example :
 Returns : 
 Args    :


=cut

sub strand{
   my ($self,@args) = @_;

   return $self->seqf->strand;
}

=head2 qualifiers

 Title   : qualifiers
 Usage   :
 Function:
 Example :
 Returns : 
 Args    :


=cut

sub qualifiers{
   my ($self,@args) = @_;

   return ();
}

sub PrimarySeq_is_available{
   my ($self,@args) = @_;

   return 0;
}

=head2 get_PrimarySeq

 Title   : get_PrimarySeq
 Usage   :
 Function:
 Example :
 Returns : 
 Args    :


=cut

sub get_PrimarySeq{
   my ($self,@args) = @_;

   throw org::Biocorba::Seqcore::UnableToProcess;
}


=head2 seqf

 Title   : seqf
 Usage   : $obj->seqf($newval)
 Function: 
 Example : 
 Returns : value of seqf
 Args    : newvalue (optional)


=cut

sub seqf{
   my ($obj,$value) = @_;
   if( defined $value) {
      $obj->{'seqf'} = $value;
    }
    return $obj->{'seqf'};

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
