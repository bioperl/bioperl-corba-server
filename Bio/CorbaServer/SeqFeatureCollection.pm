#
# BioPerl module for Bio::CorbaServer::SeqFeatureCollection
#
# Cared for by Ewan Birney <birney@ebi.ac.uk>
#
# Copyright Ewan Birney
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::CorbaServer::SeqFeatureCollection - DESCRIPTION of Object

=head1 SYNOPSIS

Give standard usage here

=head1 DESCRIPTION

  BSANE SeqFeatureCollection bindings to SEq

=head1 FEEDBACK

=head2 Mailing Lists

User feedback is an integral part of the evolution of this
and other Bioperl modules. Send your comments and suggestions preferably
 to one of the Bioperl mailing lists.
Your participation is much appreciated.

  bioperl-l@bio.perl.org

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


package Bio::CorbaServer::SeqFeatureCollection;
use vars qw(@ISA);
use strict;

# Object preamble - inherits from Bio::Root::RootI

use Bio::CorbaServer::Base;
use Bio::CorbaServer::SeqFeatureIterator;

@ISA = qw( Bio::CorbaServer::Base POA_bsane::seqcore::SeqFeatureCollection);
# new() can be inherited from Bio::Root::RootI


sub new {
    my ($class, @args) = @_;
    my $self = $class->SUPER::new(@args);
    my ($seq) = $self->_rearrange([qw(SEQ)],@args);

    if( ! defined $seq || !ref $seq || ! $seq->isa('Bio::PrimarySeqI') ) {
	$seq = '' if( !defined $seq );
	$self->throw($class ." got a non sequence [$seq] for server object");
    }
    $self->_seq($seq);
    $self->is_circular(0);  
    return $self;
}


=head2 get_annotations

 Title   : get_annotations
 Usage   : my $feats = $obj->get_annotations();
 Function: 
 Example :
 Returns : array of all the features of the sequence
 Args    : 

=cut

sub get_annotations {
    my ($self,$how_many,$iterator) = @_;
    my @sf;

    @sf = $self->_seq->top_SeqFeatures();

    my @ret = splice(@sf,0,$how_many);

    my @obj;

    foreach my $ret ( @ret ) {
	my $sfobj = new Bio::CorbaServer::SeqFeature( 'poa' => $self->poa,
						      'seqfeature' => $ret);
	
	push(@obj,$sfobj->get_activated_object_reference);
    }


    my $it = new Bio::CorbaServer::SeqFeatureIterator('-poa'   => $self->poa,
						      '-items' => \@sf);
    $iterator = $it->get_activated_obeject_reference();

    return @obj;
}


