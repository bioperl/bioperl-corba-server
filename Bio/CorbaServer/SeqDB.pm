#
# BioPerl module for Bio::CorbaServer::SeqDB
#
# Cared for by Jason Stajich <jason@chg.mc.duke.edu>
#
# Copyright Ewan Birney, Jason Stajich
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::CorbaServer::SeqDB - DESCRIPTION of Object

=head1 SYNOPSIS

Give standard usage here

=head1 DESCRIPTION

Describe the object here

=head1 FEEDBACK

=head2 Mailing Lists

User feedback is an integral part of the evolution of this
and other Bioperl modules. Send your comments and suggestions preferably
 to one of the Bioperl mailing lists.
Your participation is much appreciated.

  bioperl-l@bio.perl.org          - General discussion
  bioperl-guts-l@bio.perl.org     - Technically-oriented discussion
  http://bio.perl.org/MailList.html             - About the mailing lists

=head2 Reporting Bugs

Report bugs to the Bioperl bug tracking system to help us keep track
 the bugs and their resolution.
 Bug reports can be submitted via email or the web:

  bioperl-bugs@bio.perl.org
  http://bio.perl.org/bioperl-bugs/

=head1 AUTHOR - Ewan Birney, Jason Stajich

Email birney@ebi.ac.uk, jason@chg.mc.duke.edu

Describe contact details here

=head1 APPENDIX

The rest of the documentation details each of the object methods. Internal methods are usually preceded with a _

=cut


# Let the code begin...


package Bio::CorbaServer::SeqDB;
use vars qw($AUTOLOAD @ISA);
use strict;

# Object preamble - inherits from Bio::CorbaServer::PrimarySeqDB
use Bio::CorbaServer::PrimarySeqDB;
use Bio::CorbaServer::PrimarySeqIterator;
use Bio::CorbaServer::Seq;


@ISA = qw(POA_org::Biocorba::Seqcore::SeqDB Bio::CorbaServer::PrimarySeqDB);

sub new {
    my ($class,$poa,$name,$seqdb, @args) = @_;
    my $self = Bio::CorbaServer::PrimarySeqDB->new($poa, $name, $seqdb, @args);
    
    bless $self,$class;
    $self->{_dbname} = $name;

    # ewan - changed this to be a far more generic interface.
    if( !ref $seqdb || !$seqdb->isa('Bio::DB::SeqI') ) {
	$self->throw("Could not make a Corba Server from a non Bio::DB::SeqI interface, $seqdb");
    }
    # should we make it more generic?
    $self->seqdb($seqdb);
    return $self;
}

=head1 SeqDB Interface Routines

=head2 get_Seq

 Title   : get_Seq
 Usage   : 
 Function:
 Example :
 Returns : a sequence for a specific id
 Args    : accessor id for the sequence to return

=cut

sub get_Seq {
    my $self = shift;
    my $id   = shift;
    my $seq = $self->seqdb->fetch($id);
    
    if( defined $seq ) {
	# data marshall object out	
	my $servant = Bio::CorbaServer::Seq->new($self->poa, $seq);
	my $id = $self->poa->activate_object($servant);	
	my $temp = $self->poa->id_to_reference($id);
	return $temp;
    } else {
	throw org::Biocorba::Seqcore::UnableToProcess
	    ( reason => ref($self)." could not find seq for $id");	
    }
}

=head2 get_primaryidList

 Title   : get_primaryidList
 Usage   : $self->get_primaryidList()
 Function:
 Example :
 Returns : reference to array containing strings of all primary ids
           of contained seqs
 Args    : 

=cut

sub get_primaryidList {
    my $self = shift;    
    my @ids = $self->seqdb->get_all_primary_ids();
    return [ @ids ];
}


1;


