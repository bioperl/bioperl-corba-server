# $Id$
#
# BioPerl module for Bio::CorbaServer::PrimarySeqVector
#
# Cared for by Jason Stajich <jason@chg.mc.duke.edu>
#
# Copyright Jason Stajich
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::CorbaServer::PrimarySeqVector - a vector to hold items

=head1 SYNOPSIS
    my $vector = new Bio::CorbaServer::PrimarySeqVector('-poa' => $self->poa,
						       '-items' => \@elements);
    my $size = $vector->size;
    my $thirdelement = $vector->elementAt(2);

=head1 DESCRIPTION

This object allows vector access to stored items.

=head1 FEEDBACK

=head2 Mailing Lists

User feedback is an integral part of the evolution of this and other
Bioperl modules. Send your comments and suggestions preferably to one
of the Bioperl mailing lists.  Your participation is much appreciated.

  bioperl-l@bio.perl.org             - General discussion
  http://bio.perl.org/MailList.html  - About the mailing lists

=head2 Reporting Bugs
]
Report bugs to the Bioperl bug tracking system to help us keep track
the bugs and their resolution.  Bug reports can be submitted via email
or the web:

  bioperl-bugs@bio.perl.org
  http://bio.perl.org/bioperl-bugs/

=head1 AUTHOR - Jason Stajich

Email jason@chg.mc.duke.edu

=head1 APPENDIX

The rest of the documentation details each of the object
methods. Internal methods are usually preceded with a _

=cut

# Let the code begin...

package Bio::CorbaServer::PrimarySeqVector;

use vars qw($AUTOLOAD @ISA);
use strict;

use Bio::CorbaServer::Base;
use Bio::CorbaServer::PrimarySeqIterator;

@ISA = qw(POA_org::biocorba::seqcore::PrimarySeqVector Bio::CorbaServer::Base);

sub new {
    my ($class, @args) = @_;    
    my $self = $class->SUPER::new(@args);
    my ($items) = $self->_rearrange([qw(ITEMS)], @args);

    if( $items && ref($items) !~ /array/i ) {
	throw org::biocorba::seqcore::UnableToProcess 
	    reason => "initializing a $class with an invalid argument ($items) instead of an array of items";
    }
    if( !defined $items ) {
	$items = [];
    }
    $self->_elements($items);
    return $self;
}


=head2 size

 Title   : size
 Usage   : my $len = $obj->size
 Function: returns the number elements stored
 Example : 
 Returns : size of array
 Args    : none

=cut

sub size {
    my ($self) = @_;
    return scalar @{$self->{'_elements'}};
}


=head2 elementAt

 Title   : elementAt
 Usage   : my $item = $obj->elementAt(2);
 Function: returns the item stored at 2
 Example : 
 Returns : size of array
 Args    : none

=cut

sub elementAt {
    my ($self,$index) = @_;
    if( $index > $self->size || $index < 0 ) {
	throw org::biocorba::seqcore::OutOfRange 
	    reason => "index $index is out of range (0,".$self->size.").";
    }
    return $self->{'_elements'}->[$index];
}

=head2 iterator

 Title   : iterator
 Usage   : my $iter = $obj->iterator();
 Function: returns an Bio::CorbaServer::PrimarySeqIterator
 Example : 
 Returns : iterator
 Args    : none

=cut

sub iterator {
    my ($self) = @_;
    my $iter = new Bio::CorbaServer::PrimarySeqIterator('-poa' => $self->poa, 
							'-items' => $self->_elements);
    return $iter->get_activated_object_reference();
}

=head2 _elements

 Title   : _elements
 Usage   : $self->_elements($itemarrayref)
 Function: update local array
 Example : 
 Returns : element array
 Args    : arrayref to items to store in the local array

=cut

sub _elements {
    my ($self,$elements) = @_;
    if( $elements ) {
	$self->{'_elements'} = $elements;   
    } 
    return $self->{'_elements'};
}

1;
