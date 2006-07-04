# $Id$
#
# BioPerl module for Bio::CorbaServer::Symbol
#
# Cared for by Jason Stajich <jason@bioperl.org>
#
# Copyright Jason Stajich
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::CorbaServer::Symbol - A Symbol as part of an alphabet

=head1 SYNOPSIS
    
    use Bio::CorbaServer::Symbol;
    my $symbol = new Bio::CorbaServer::Symbol(-symbol => $bioperlsymbolobj,
 					      -poa    => $poa);
    $symbol->get_activated_object_reference;

=head1 DESCRIPTION

This is a wrapper for BSANE/BioCORBA objects around Bioperl objects.  

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


package Bio::CorbaServer::Symbol;
use vars qw(@ISA);
use strict;

use Bio::CorbaServer::Base;
use Bio::CorbaServer::Alphabet;
use Bio::Symbol::Alphabet;

@ISA = qw(POA_bsane::Symbol Bio::CorbaServer::Base);

=head2 new

 Title   : new
 Usage   : my $obj = new Bio::CorbaServer::Symbol();
 Function: Builds a new Bio::CorbaServer::Symbol object 
 Returns : Bio::CorbaServer::Symbol
 Args    :-poa => POA string
          -symbol => Bio::Symbol::SymbolI object


=cut

sub new {
  my($class,@args) = @_;

  my $self = $class->SUPER::new(@args);
  my ($symbol) = $self->_rearrange([qw(SYMBOL)], @args);
  $self->_symbol($symbol);
  return $self;
}

=head2 bsane::Symbol methods

=head2 get_name

 Title   : get_name
 Usage   : my $name = $symbol->get_name()
 Function: Gets the name of this symbol
 Returns : string
 Args    : none


=cut

sub get_name{
   my ($self) = @_;
   return $self->_symbol->name();
}

=head2 get_token

 Title   : get_token
 Usage   : my $token = $symbol->get_token()
 Function: Gets the token for this symbol
 Returns : string
 Args    : none


=cut

sub get_token{
   my ($self) = @_;
   return $self->_symbol->token();
}

=head2 get_symbols

 Title   : get_symbols
 Usage   : my @symbols = $symbol->get_symbols();
 Function: gets the list of symbols this symbol was composed of (if any) 
 Returns : List of bsane::Symbol objects (bsane::SymbolList)
 Args    : none


=cut

sub get_symbols{
   my ($self) = @_;
   my $ref = [];
   foreach my $s ($self->_symbol->symbols()) {
       my $sym = new Bio::CorbaServer::Symbol('-poa' => $self->poa,
					      '-symbol' => $s);       
       push @$ref, $sym->get_activated_object_reference();

   }       
   return $ref;
}

=head2 get_matches

 Title   : get_matches
 Usage   : my $alphabet = $symbol->get_matches();
 Function: (Sub) alphabet of symbols matched by this symbol including
           the symbol itself (i.e. if symbol is DNA ambiguity code W
           then the matches contains symbols for W and T)
 Returns : bsane::Alphabet 
 Args    : none

=cut

# probably wrong here!
sub get_matches {
   my ($self) = @_;
   my $alphabet = new Bio::Symbol::Alphabet
       (-symbols => [ $self->_symbols->tokens(), $self]);
   
   my $a = new Bio::CorbaServer::Alphabet(-alphabet => $alphabet);
   return $a-> get_activated_object_reference();
}

=head2 Private Methods

=head2 _symbol

 Title   : _symbol
 Usage   : $obj->_symbol($newval)
 Function: 
 Example : 
 Returns : value of _symbol
 Args    : newvalue (optional)


=cut

sub _symbol{
   my ($self,$value) = @_;
   if( defined $value) {
      $self->{'_symbol'} = $value;
    }
    return $self->{'_symbol'};

}


1;
