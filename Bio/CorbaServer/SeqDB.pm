
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

  vsns-bcd-perl@lists.uni-bielefeld.de          - General discussion
  vsns-bcd-perl-guts@lists.uni-bielefeld.de     - Technically-oriented discussion
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

# Object preamble - inherits from Bio::Root::Object
use Bio::CorbaServer::Base;
use Bio::CorbaServer::PrimarySeqIterator;
use Bio::Index::Fasta;

@ISA = qw( Bio::CorbaServer::Base POA_org::Biocorba::Seqcore::SeqDB);

sub new {
    my ($class,$poa,$name,$indexfile) = @_;
    my $self = Bio::CorbaServer::Base->new($poa);
    
    bless $self,$class;
    $self->{_dbname} = $name;
    # should we make it more generic?
    $self->seqdb( Bio::Index::Fasta->new(
					 -filename    =>$indexfile,
					 -write_flag  =>0,
					 -verbose     =>0));
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
    my $seq = $self->seqdb->get_Seq_by_primary_id($id);
    
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

sub get_primaryidList {
    my $self = shift;
    return $self->seqdb->get_all_primary_ids
}


=head1 PrimarySeqDB Interface Routines

=head2 database_name

 Title   : database_name
 Usage   : 
 Function:
 Example :
 Returns : database name
 Args    : 

=cut

sub database_name {
    my $self = shift;
    return $self->{_dbname};
}

=head2 database_version

 Title   : database_version
 Usage   : 
 Function:
 Example :
 Returns : database version
 Args    : 

=cut

sub database_version {
    my $self = shift;
    return $self->seqdb->_version;
}

=head2 make_PrimarySeqIterator

 Title   : make_PrimarySeqIterator
 Usage   : 
 Function:
 Example :
 Returns : an iterator over all the primary seqs
           available on this object
 Args    : 

=cut

sub make_PrimarySeqIterator {
    my $self = shift;
    my $seqio = $self->seqdb->get_PrimarySeq_stream;
    my $servant = Bio::CorbaServer::PrimarySeqIterator->new($self->poa,
							    $seqio);
    # data marshall object out    
    my $id = $self->poa->activate_object($servant);
    my $temp = $self->poa->id_to_reference($id);
    return $temp;

}

=head2 get_PrimarySeq

 Title   : get_PrimarySeq
 Usage   : 
 Function:
 Example :
 Returns : a primary sequence for a specific id
 Args    : accessor id for the sequence to return

=cut

sub get_PrimarySeq {
    # throws (UnableToProcess)
    my $self = shift;
    my $id = shift;

    my $seq = $self->seqdb->get_PrimarySeq_by_primary_id($id);

    if( defined $seq ) {
	my $servant = Bio::CorbaServer::Seq->new($self->poa, $seq);
	# data marshall object out
	my $id = $self->poa->activate_object($servant);
	my $temp = $self->poa->id_to_reference($id);
	return $temp;
    } else {
	throw org::Biocorba::Seqcore::UnableToProcess
	    ( reason => ref($self)." could not find seq for $id");
    }
}

=head1 Local Package methods

Non IDL defined methods

=head2 seqdb

 Title   : seqdb
 Usage   : 
 Function:
 Example :
 Returns : reference to seqdb object
 Args    : 

=cut

sub seqdb {
    my ($self,$value) = @_;
    $self->{_seqdb} = $value if ( defined $value);
    return $self->{_seqdb};
}


1;
