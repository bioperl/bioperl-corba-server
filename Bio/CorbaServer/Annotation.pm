# $Id$
#
# BioPerl module for Bio::CorbaServer::Annotation
#
# Cared for by Jason Stajich <jason@bioperl.org>
#
# Copyright Jason Stajich
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::CorbaServer::Annotation - DESCRIPTION of Object

=head1 SYNOPSIS

Give standard usage here

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


package Bio::CorbaServer::Annotation;
use vars qw(@ISA);
use strict;
use Bio::CorbaServer::Base;

@ISA = qw( POA_bsane::seqcore::BioSequence Bio::CorbaServer::Base );

=head2 new

 Title   : new
 Usage   : my $obj = new Bio::CorbaServer::Annotation();
 Function: Builds a new Bio::CorbaServer::Annotation object 
 Returns : Bio::CorbaServer::Annotation
 Args    :


=cut

sub new {
  my($class,@args) = @_;

  my $self = $class->SUPER::new(@args);
  ($self->{'_name'},
   $self->{'_basis'},
   $self->{'_value'}) = $self->_rearrange([qw(NAME BASIS VALUE)],@args);
  
  return $self;
}

=head2 bsane::Annotation methods

=head2 get_name

 Title   : get_name
 Usage   : my $name = $annotation->get_name()
 Function: Returns the general type of the annotation
 Returns : string
 Args    : none


=cut

sub get_name{
   my ($self) = @_;
   return $self->{'_name'};
}

=head2 get_basis

 Title   : get_basis
 Usage   : my $basis = $annotation->get_basis();
 Function: Returns the basis for an annotation
           valid types are
           NOT_KNOWN=0
           EXPERIMENTAL=1
           COMPUTATIONAL=2
           BOTH=3
           NOT_APPLICABLE=4
 Returns : numeric representing one of the above
 Args    : none

=cut

sub get_basis{
   my ($self) = @_;
   return 0 if ! defined $self->{'_basis'} || $self->{'_basis'} !~ /^[0-4]/;
   return $self->{'_basis'} ;
}

=head2 get_value

 Title   : get_name
 Usage   : my $name = $annotation->get_value()
 Function: Returns the data for the annotation
 Returns : any
 Args    : none
 Note    : Not sure this will really work in perl

=cut

sub get_value{
   my ($self) = @_;
   return $self->{'_value'};
}

1;
