
#
# BioPerl module for Bio::CorbaServer::Server
#
# Jason Stajich <jason@chg.mc.due.edu>
#
# Copyright Jason Stajich
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::CorbaServer::Server - BioCorba basic server object used for
allocating other BioCorba objects

=head1 SYNOPSIS

    use Bio::CorbaServer::Server;
    # in this example we build a SeqDB
    # have a SeqDB object already called $seqdbref
    my $server = new Bio::CorbaServer::Server( -idl => 'biocorba.idl',
					       -ior => 'srv.ior',
					       -orbname=> 'orbit-local-orb');
    my $seqdb = $server->new_object( -object=> 'Bio::CorbaServer::SeqDB',
				     -args => [ 'dbname-here', $seqdbref ] );

    $server->start();

=head1 DESCRIPTION

This object provides BioCorba object creation support.

=head1 FEEDBACK

=head2 Mailing Lists

User feedback is an integral part of the evolution of this and other
Bioperl modules. Send your comments and suggestions preferably to one
of the Bioperl mailing lists.  Your participation is much appreciated.

  bioperl-l@bioperl.org                 - BioPerl discussion
  biocorba-l@biocorba.org               - BioCorba discussion
  http://www.bioperl.org/MailList.html  - About the BioPerl mailing list
  http://www.biocorba.org/MailList.html - About the BioCorba mailing list

=head2 Reporting Bugs

Report bugs to the Bioperl bug tracking system to help us keep track
 the bugs and their resolution.
 Bug reports can be submitted via email or the web:

  bioperl-bugs@bio.perl.org
  http://bio.perl.org/bioperl-bugs/

=head1 AUTHOR - Jason Stajich

Email jason@chg.mc.duke.edu    


=head1 APPENDIX

The rest of the documentation details each of the object methods. Internal methods are usually preceded with a _

=cut

# object code begins
    
package Bio::CorbaServer::Server;

BEGIN { 
    die('Must defined ENV variable BIOCORBAHOME') 
	unless ( defined $ENV{'BIOCORBAHOME'} );
}

use vars qw(@ISA);
use strict;
use CORBA::ORBit idl => [ "$ENV{BIOCORBAHOME}/idl/seqcore.idl" ];
use Bio::Root::RootI;

@ISA = qw ( Bio::Root::RootI );

sub new { 
    my ( $class, @args) = @_;
    my $self = $class->SUPER::new(@args);

    my ( $idl, $ior, $orbname ) = $self->_rearrange( [ qw(IDL IOR ORBNAME)], 
						     @args);

    $self->{'_ior'} = $ior || 'biocorba.ior';
    $self->{'_idl'} = $idl || $ENV{BIOCORBAIDL} || 'biocorba.idl';
    $self->{'_orbname'} = $orbname || 'orbit-local-orb';
    $CORBA::ORBit::IDL_PATH = $self->{'_idl'};
    my $orb = CORBA::ORB_init($orbname);
    my $root_poa = $orb->resolve_initial_references("RootPOA");
    
    $self->{'_orb'} = $orb;
    $self->{'_rootpoa'} = $root_poa;
    return $self;
}

sub start { 
    my ($self) = @_;    
    open(OUT, ">" . $self->{'_ior'}) || 
	$self->throw("cannot open ior file " . $self->{'_ior'}); 
    foreach my $object ( @{$self->{'_serverobjs'}} ) { 
	my $id = $self->{'_rootpoa'}->activate_object($object);
	my $objref = $self->{'_rootpoa'}->id_to_reference($id);
	print OUT $self->{'_orb'}->object_to_string($objref), "\n";
    }
    close OUT;
    print STDERR "activated server objects, starting server\n";
    $self->{'_rootpoa'}->_get_the_POAManager->activate;
    $self->{'_orb'}->run;
}

sub new_object {
    my ($self, @args) = @_;

    my ( $objectname, $args) = $self->_rearrange( [qw(OBJECT ARGS)], 
						  @args);
    
    $self->throw("must have an object name before server can allocate a new object\n")
	if( !defined $objectname );
    
    my $obj;
    if ( &_load_module($objectname) == 0 ) { # normalize capitalization
	return undef;
    }    
    # create the new object with a no_destroy flag so it can be accessed
    # by multiple clients
    $obj = $objectname->new( '-poa' => $self->{'_rootpoa'}, 
			     @$args, '-no_destroy' => 1 );    
    if( @$ || !defined $obj ) { 
	$self->throw("Cannot instantiate object of type $objectname");
    }
    push @{$self->{'_serverobjs'}}, $obj;
    return $obj;
}

=head2 _load_module

 Title   : _load_module
 Usage   : *INTERNAL BioCorba Server stuff*
 Function: Loads up (like use) a module at run time on demand
 Example :
 Returns :
 Args    :

=cut

sub _load_module {
  my ($format) = @_;
  my ($module, $load, $m);
  $format =~ s/::/\//g;
  $load = "$format.pm";
  $module = "_<$format.pm";
  
  return 1 if $main::{$module};
  eval {
    require $load;
  };
  if ( $@ ) {
    print STDERR <<END;
$load: $format cannot be found
Exception $@
For more information about the Bio::CorbaServer::Server system 
please see the Bio::CorbaServer::Server docs.
This includes ways of checking for formats at compile time, not run time
END
;
    return 0;
  }
  return 1;
}
