# $Id$
#
# BioPerl module for Bio::CorbaServer::SeqIterator
#
# Cared for by Jason Stajich <jason@bioperl.org>
#
# Copyright Jason Stajich
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::CorbaServer::SeqIterator - An iterator for Sequences

=head1 SYNOPSIS

Give standard usage here

=head1 DESCRIPTION

Describe the object here

=head1 FEEDBACK

=head2 Mailing Lists

User feedback is an integral part of the evolution of this and other
Bioperl modules. Send your comments and suggestions preferably to
the Bioperl mailing list.  Your participation is much appreciated.

  bioperl-l@bioperl.org                  - General discussion
  http://bioperl.org/wiki/Mailing_lists  - About the mailing lists

=head2 Reporting Bugs

Report bugs to the Bioperl bug tracking system to help us keep track
of the bugs and their resolution. Bug reports can be submitted via
the web:

  http://bugzilla.open-bio.org/

=head1 AUTHOR - Jason Stajich

Email jason@bioperl.org

Describe contact details here

=head1 CONTRIBUTORS

Additional contributors names and emails here

=head1 APPENDIX

The rest of the documentation details each of the object methods.
Internal methods are usually preceded with a _

=cut


# Let the code begin...


package Bio::CorbaServer::SeqIterator;
use vars qw(@ISA);
use strict;

use Bio::CorbaServer::Base;
use Bio::CorbaServer::Seq;
use Bio::CorbaServer::PrimarySeq;

@ISA = qw(POA_bsane::Iterator Bio::CorbaServer::Base );

=head2 new

 Title   : new
 Usage   : my $obj = new Bio::CorbaServer::SeqIterator();
 Function: Builds a new Bio::CorbaServer::SeqIterator object 
 Returns : Bio::CorbaServer::SeqIterator
 Args    : -poa   => POA reference
           -seqio => Bio::SeqIO reference for the iterator 


=cut

sub new {
  my($class,@args) = @_;

  my $self = $class->SUPER::new(@args);
  
  my ($seqio) = $self->_rearrange([qw(SEQIO)],@args);
  if( ! defined $seqio || !ref($seqio) || ! $seqio->isa('Bio::SeqIO') ) {
      $self->throw("Must have defined a Bio::SeqIO when initializing a SeqIterator");
  }
  $self->_seqio($seqio);
  $self->{'ready'} = 1;
  return $self;
}

=head2 next

 Title   : next
 Usage   : my $item = $self->next()
 Function: returns next item in iterator list
 Returns : Bio::CorbaServer::PrimarySeq
 Args    : $item OUT parameter and boolean if more data available

=cut

sub next {
    my ($self,$item) = @_;
    if( ! defined $self->_seqio ) {
	throw bsane::IteratorInvalid('reason' => 'SeqIO has been resent in Perl Iterator implementation');
    }
    my $next = $self->_seqio->next_seq;
    if( ! defined $next ) {
	return (0,undef);
#	throw bsane::IteratorInvalid('reason' => 'End of Sequence stream reached');
    }
    if( $next->isa('Bio::SeqI') ) {
	$item = new Bio::CorbaServer::Seq('-poa' => $self->poa,
					  '-seq' => $next);
    } elsif( $next->isa('Bio::PrimarySeqI') ) {
	$item = new Bio::CorbaServer::PrimarySeq('-poa' => $self->poa,
						 '-seq' => $next);
    } else { 
	return 0, undef;
    }
    my $ref = $item->get_activated_object_reference;
    return (1,$ref);
}

=head2 next_n

 Title   : next_n
 Usage   : my @items = $self->next_n($count);
 Function: Returns the next $count sequences
 Returns : List of Sequences
 Args    : Count of sequences


=cut

sub next_n{
    my ($self,$count) = @_;
    if( ! defined $self->_seqio ) {
	throw bsane::IteratorInvalid('reason' => 'SeqIO has been resent in Perl Iterator implementation');
    }
    my $counter = 0;
    my @list;
    while( $counter < $count ) {
	my $next = $self->_seqio->next_seq;
	last unless (defined $next );
	my $item;
	if( $next->isa('Bio::SeqI') ) {
	    $item = new Bio::CorbaServer::Seq('-poa' => $self->poa,
					      '-seq' => $next);
	} elsif( $next->isa('Bio::PrimarySeqI') ) {
	    $item = new Bio::CorbaServer::PrimarySeq('-poa' => $self->poa,
						     '-seq' => $next);
	} 
	my $ref = $item->get_activated_object_reference;
	push @list, $ref;
	$counter++;
    }
    return ($counter > 0 ,\@list);
}

=head2 _seqio

 Title   : _seqio
 Usage   : $obj->_seqio($newval)
 Function: 
 Example : 
 Returns : value of _seqio
 Args    : newvalue (optional)


=cut

sub _seqio{
   my ($self,$value) = @_;
   if( defined $value) {
      $self->{'_seqio'} = $value;
    }
    return $self->{'_seqio'};

}

1;
