# $Id$
#
# BioPerl module for Bio::CorbaServer::Base
#
# Cared for by Ewan Birney <birney@ebi.ac.uk>
#
# Copyright Ewan Birney
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::CorbaServer::Base - BioCorba Base Object, all BioCorba object inherit and are created from it.

=head1 SYNOPSIS

# Do not use this object directly
# get a biocorba object somehow

    my $poa = $obj->poa;

=head1 DESCRIPTION

This is the base object for all perl BioCorba objects, and manages
reference counts and references to the poa.

=head1 FEEDBACK

=head2 Mailing Lists

User feedback is an integral part of the evolution of this and other
Bioperl modules. Send your comments and suggestions preferably to one
of the Bioperl mailing lists.  Your participation is much appreciated.

  bioperl-l@bio.perl.org            - General discussion
  http://bio.perl.org/MailList.html - About the mailing lists

=head2 Reporting Bugs

Report bugs to the Bioperl bug tracking system to help us keep track
 the bugs and their resolution.  Bug reports can be submitted via
 email or the web:

  bioperl-bugs@bio.perl.org
  http://bio.perl.org/bioperl-bugs/

=head1 AUTHOR - Ewan Birney, Jason Stajich

Email birney@ebi.ac.uk
      jason@chg.mc.duke.edu

Describe contact details here

=head1 APPENDIX

The rest of the documentation details each of the object
methods. Internal methods are usually preceded with a _

=cut

# Let the code begin...

package Bio::CorbaServer::Base;
use vars qw($AUTOLOAD @ISA);
use strict;

use Bio::Root::RootI;

@ISA = qw(Bio::Root::RootI);

sub new {
    my ($class, @args) = @_;
        my $self = $class->SUPER::new(@args);

    my ($poa, $no_destroy) = $self->_rearrange([qw(POA NO_DESTROY)], @args);

    $self->_no_destroy($no_destroy);

    $self->poa($poa);
    $self->reference_count(1);
    return $self;
}

sub ref {
    my $self = shift;
    $self->{'reference_count'}++;
}

sub unref {
    my $self = shift;
    if( $self->reference_count == 1 ) {
	if (!($self->_no_destroy)) {
	    $self->poa->deactivate_object ($self->poa->servant_to_id ($self));
	}
    }
    $self->{'reference_count'}--;
}

=head2 poa

 Title   : poa
 Usage   : $obj->poa($newval)
 Function: 
 Example : 
 Returns : value of poa
 Args    : newvalue (optional)


=cut

sub poa {
    my ($obj,$value) = @_;
    if( defined $value) {
	$obj->{'poa'} = $value;
    }
    return $obj->{'poa'};
}

=head2 reference_count

 Title   : reference_count
 Usage   : $obj->reference_count($newval)
 Function: 
 Example : 
 Returns : value of reference_count
 Args    : newvalue (optional)


=cut

sub reference_count {
    my ($obj,$value) = @_;
    if( defined $value) {
	$obj->{'reference_count'} = $value;
    }
    return $obj->{'reference_count'};
}

=head2 query_interface

 Title   : query_interface
 Usage   : my $objq = $obj->query_interface($repoid)
 Function: The query_interface is not important for this case, 
           but here for completeness.
 Example : 
 Returns : 
 Args    : 

=cut

sub query_interface { return $_[0]; }

sub _no_destroy {
    my($self,$value) = @_;
    if( defined $value || !defined $self->{'_no_destroy'}) {
	$value = 0 if( ! defined $value );
	$self->{'_no_destroy'} = $value;
    }
    return $self->{'_no_destroy'};
}
1;
