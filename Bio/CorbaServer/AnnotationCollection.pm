# $Id$
#
# BioPerl module for Bio::CorbaServer::AnnotationCollection
#
# Cared for by Jason Stajich <jason@bioperl.org>
#
# Copyright Jason Stajich
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::CorbaServer::AnnotationCollection - A BioCORBA AnnotationCollection which maps to a Bioperl Bio::AnnotationCollectionI

=head1 SYNOPSIS
    # get a CorbaSeq somehow
    my $collection = $corbaseq->get_annotations();
    print "annotation count is ", $collection->get_num_annotations, "\n";
  
=head1 DESCRIPTION

Describe the object here

=head1 FEEDBACK

=head2 Mailing Lists

User feedback is an integral part of the evolution of this and other
Bioperl modules. Send your comments and suggestions preferably to
the Bioperl mailing list.  Your participation is much appreciated.

  bioperl-l@bioperl.org              - General discussion
  http://bioperl.org/MailList.shtml  - About the mailing lists

=head2 Reporting Bugs

Report bugs to the Bioperl bug tracking system to help us keep track
of the bugs and their resolution. Bug reports can be submitted via
email or the web:

  bioperl-bugs@bioperl.org
  http://bioperl.org/bioperl-bugs/

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


package Bio::CorbaServer::AnnotationCollection;
use vars qw(@ISA);
use strict;

use Bio::CorbaServer::Base;

BEGIN { print STDERR "Accessing this module\n"; };

@ISA = qw( POA_bsane::AnnotationCollection Bio::CorbaServer::Base );

=head2 new

 Title   : new
 Usage   : my $col = new Bio::CorbaServer::AnnotationCollection(-poa => $poa,
								-collection=> $col);
 Function: Instatiates a new Bio::CorbaServer::AnnotationCollection
 Returns : Bio::CorbaServer::AnnotationCollection
 Args    : -poa => POA 
           -collection => Bio::AnnotationCollectionI object

=cut

sub new {
    my ($class, @args) = @_;
    my $self = $class->SUPER::new(@args);
    my ($col) = $self->_rearrange([qw(COLLECTION)],@args);

    if( ! defined $col || !ref $col || ! $col->isa('Bio::AnnotationCollectionI') ) {
	$col = '' if( !defined $col );
	$self->throw($class ." got a non AnnotationCollection [$col] for server object");
    }
    $self->_collection($col);
    return $self;
}

=head2 get_num_annotations

 Title   : get_num_annotations
 Usage   : my $num = $collection->get_num_annotations()
 Function: Returns the number of Annotations stored by this object
 Returns : unsigned long
 Args    : none


=cut

sub get_num_annotations{
   my ($self) = @_;
   return $self->_collection->get_num_of_annotations;
}

=head2 get_annotations

 Title   : get_annotations
 Usage   : my @list = $collection->get_annotations($count,$iterator);
 Function: Return the annotations for this collection
 Returns : List of annotation objects
 Args    :


=cut

sub get_annotations{
   my ($self,$howmany,$iterator) = @_;

   my @data;
   foreach my $key ( $self->_collection->get_all_annotation_keys() ) {
       my @values = $self->_collection->get_Annotations($key);
       foreach  ( @values ) {
	   my $a = new Bio::CorbaServer::Annotation('-poa'   => $self->poa,
						    '-name'  => $key,
						    '-basis' => 4,# hard coded for now
						    '-value' => $_);
	   push @data, $a->get_activated_object_reference();
       }
   }
   my @values;
   for(my $i = 0; $i < $howmany; $i++ ) {
       push @values, shift @data;
   }
   $iterator = new Bio::CorbaServer::Iterator('-poa' => $self->poa,
					      '-items' => \@data);
   return @values;
}

=head2 _collection

 Title   : _collection
 Usage   : $obj->_collection($newval)
 Function: 
 Example : 
 Returns : value of _collection
 Args    : newvalue (optional)


=cut

sub _collection{
   my ($self,$value) = @_;
   if( defined $value) {
      $self->{'_collection'} = $value;
    }
    return $self->{'_collection'};
}

1;
