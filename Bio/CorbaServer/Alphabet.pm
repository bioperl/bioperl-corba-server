# $Id $
#
# BioPerl module for Bio::CorbaServer::Alphabet
#
# Cared for by Jason Stajich <jason@bioperl.org>
#
# Copyright Jason Stajich
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::CorbaServer::Alphabet - Object to handle Alphabets for BioCORBA

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

package Bio::CorbaServer::Alphabet;
use vars qw(@ISA);
use strict;

use Bio::CorbaServer::Base;
use Bio::CorbaServer::Symbol;
use Bio::Symbol::Symbol;
use Bio::Symbol::Alphabet;

@ISA = qw(POA_bsane::Alphabet Bio::CorbaServer::Base );

sub new {
  my($class,@args) = @_;
  my $self = $class->SUPER::new(@args);
  my ($alphabet) = $self->_rearrange([qw(ALPHABET)],@args);
  if( ! $alphabet || ! $alphabet->isa('Bio::Symbol::AlphabetI') ) {
      throw bsane::DoesNotExist( 'reason' => "Did not pass in a valid Bio::Alphabet object");
  }
  $self->_alphabet($alphabet);
  return $self;
}

=head2 get_symbols
    
 Title   : get_symbols
 Usage   :
 Function:
 Example :
 Returns : 
 Args    :


=cut

sub get_symbols {
    my ($self,@args) = @_;        
    my $list = [];
    foreach my $s (  $self->_alphabet->symbols ) {
	my $symb = new Bio::CorbaServer::Symbol('-symbol' => $s,
						'-poa'    => $self->poa);
	push @$list, $symb->get_activated_object_reference();
    }
    return $list;
}

=head2 get_ambiguity

 Title   : get_ambiguity
 Usage   :
 Function:
 Example :
 Returns : 
 Args    :


=cut

sub get_ambiguity{
    my ($self,$list) = @_;

    if( ! $list || ref($list) !~ /array/i ) {       
	throw bsane::IllegalSymbolException( 'reason' => "Did not specify a valid SymbolList to get_ambiguity");
    }
    my @insymbols;
    foreach my $s ( @$list ) {
	my $insymbol = new Bio::Symbol::Symbol(-token => $s->get_token(),
					       -name  => $s->get_name());
	if( ! $self->_alphabet->contains($insymbol) ) {
	    throw bsane::IllegalSymbolException( 'reason' => "Symbol ". $s->get_token() . " is not a valid symbol");
	}
	push @insymbols, $insymbol;
    }
  SYMBOL: foreach my $s ( $self->_alphabet->symbols ) {	      
      foreach $a ( @insymbols ) { 
	  if( ! $s->matches || ! $s->matches->contains($a) ) {
	      next SYMBOL;
	  }
      }
      # only end up here if the above loop executes successfully
      
      my $amb = new Bio::CorbaServer::Symbol('-poa' => $self->poa,
					     '-symbol' => $s);
      return $amb->get_activated_object_reference();
  }
    throw bsane::IllegalSymbolException( 'reason' => "None of the symbols in this alphabet are an ambiguity symbol for the requested symbols");

}



=head2 _alphabet

 Title   : _alphabet
 Usage   : $obj->_alphabet($newval)
 Function: 
 Example : 
 Returns : value of _alphabet
 Args    : newvalue (optional)


=cut

sub _alphabet{
   my ($self,$value) = @_;
   if( defined $value) {
      $self->{'_alphabet'} = $value;
    }
    return $self->{'_alphabet'};
}

1;
