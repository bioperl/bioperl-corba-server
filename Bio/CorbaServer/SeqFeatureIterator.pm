# $Id$
#
# BioPerl module for Bio::CorbaServer::SeqFeatureIterator
#
# Cared for by Jason Stajich <jason@chg.mc.duke.edu>
#
# Copyright Jason Stajich
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::CorbaServer::SeqFeatureIterator - a iterator over a list of SeqFeatures

=head1 SYNOPSIS

    my $iterator = $vector->iterator();
    while( $iterator->has_more ) {
	my $item = $iterator->next();
    }

=head1 DESCRIPTION

This object allows iteration through a list of SeqFeatures.

=head1 FEEDBACK

=head2 Mailing Lists

User feedback is an integral part of the evolution of this and other
Bioperl modules. Send your comments and suggestions preferably to one
of the Bioperl mailing lists.  Your participation is much appreciated.

  bioperl-l@bio.perl.org             - General discussion
  http://bio.perl.org/MailList.html  - About the mailing lists

=head2 Reporting Bugs

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

package Bio::CorbaServer::SeqFeatureIterator;

use vars qw($AUTOLOAD @ISA);
use strict;

use Bio::CorbaServer::Base;

@ISA = qw(POA_org::biocorba::seqcore::SeqFeatureIterator 
	Bio::CorbaServer::Base);

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
    $self->{'_pointer'} = 0;
   return $self;
}

=head2 has_more

 Title   : has_more
 Usage   : $self->has_more()
 Function: has more elements to iterate towards
 Returns : boolean
 Args    : none

=cut

sub has_more {
    my ($self) = @_;
    return( $self->{'_pointer'} < scalar @{$self->_elements} );
}

=head2 next

 Title   : next
 Usage   : my $item = $self->next()
 Function: returns next item in iterator list
 Returns : Bio::CorbaServer::PrimarySeq
 Args    : none

=cut

sub next {
    my ($self) = @_;
    my $item = $self->_elements->[$self->{'_pointer'}];
    $self->{'_pointer'}++;
    my $s = new Bio::CorbaServer::SeqFeature('-poa' => $self->poa,
					     '-seqfeature' => $item);
    return $s->get_activated_object_reference;
}

=head2 _elements

 Title   : _elements
 Usage   : $self->_elements($itemarrayref)
 Function: update local array
 Example : 
 Returns : element array
 Args    : items to store in the local array

=cut

sub _elements {
    my ($self,$elements) = @_;
    if( $elements && ref($elements) =~ /array/i ) {
	$self->{'_elements'} = $elements;
    } 
    return $self->{'_elements'};
}

1;
