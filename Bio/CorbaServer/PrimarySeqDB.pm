# $Id$
#
# BioPerl module for Bio::CorbaServer::PrimarySeqDB
#
# Cared for by Jason Stajich <jason@chg.mc.duke.edu>
#
# Copyright Ewan Birney, Jason Stajich
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::CorbaServer::PrimarySeqDB - Database of PrimarySeqs

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
the bugs and their resolution.  Bug reports can be submitted via email
or the web:

  bioperl-bugs@bio.perl.org
  http://bio.perl.org/bioperl-bugs/

=head1 AUTHOR - Ewan Birney, Jason Stajich

Email birney@ebi.ac.uk, jason@chg.mc.duke.edu

Describe contact details here

=head1 APPENDIX

The rest of the documentation details each of the object
methods. Internal methods are usually preceded with a _

=cut


# Let the code begin...

package Bio::CorbaServer::PrimarySeqDB;
use vars qw($AUTOLOAD @ISA $DBCOUNT);
use strict;
BEGIN { $DBCOUNT = 0; }
# Object preamble - inherits from Bio::Root::Object
use Bio::CorbaServer::Base;
use Bio::CorbaServer::PrimarySeqVector;
use Bio::CorbaServer::PrimarySeq;
use Bio::CorbaServer::Seq;

@ISA = qw(POA_org::biocorba::seqcore::PrimarySeqDB Bio::CorbaServer::Base);

sub new { 
    my ($class,@args) = @_;
    my $self = $class->SUPER::new(@args);
    my ($name,$seqdb) = $self->_rearrange([qw(NAME SEQDB)], @args); 

    # ewan - changed this to be a far more generic interface.
    # should we make it more generic?
    if( ! ref $seqdb || ! $seqdb->isa('Bio::DB::SeqI') ) {
	$self->throw("Could not make a Corba Server from a non Bio::DB::SeqI interface, $seqdb")
        #throw org::biocorba::seqcore::UnableToProcess 
	#    reason=>"Could not make a Corba Server from a non Bio::DB::SeqI interface, $seqdb";
    }
    $DBCOUNT++;
    $self->{'_dbname'} = $name || "unknow-$DBCOUNT";
    $self->_seqdb($seqdb);
    return $self;
}

=head1 PrimarySeqDB Interface Routines

=head2 name

 Title   : name
 Usage   : my $name = $db->name
 Function: get database name
 Returns : database name 
 Args    : 

=cut

sub name {
    my $self = shift;
    return $self->{'_dbname'};
}

=head2 version

 Title   : version
 Usage   : 
 Function: get database version value
 Returns : database version (long)
 Args    : 

=cut

sub version {
    my $self = shift;
    return $self->seqdb->_version;
}

=head2 get_PrimarySeqVector

 Title   : get_PrimarySeqVector
 Usage   : my $vector = $obj->get_PrimarySeqVector()
 Function:
 Returns : vector which contains all the PrimarySeq objects in database
 Args    : 

=cut

sub get_PrimarySeqVector {
    my ($self) = @_;
    my $seqio = $self->_seqdb->get_PrimarySeq_stream();    
    my @obj;
    while( my $seq = $seqio->next_primary_seq ) { 
	push @obj,
	new Bio::CorbaServer::Seq('-poa'=>$self->poa, '-seq' => $seq); 
    }
    my $vector = new Bio::CorbaServer::PrimarySeqVector('-poa'=> $self->poa,
							'-items' => \@obj);
    my $id = $self->poa->activate_object($vector);
    my $temp = $self->poa->id_to_reference ($id);
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
    my ($self,$id) = @_;
    my $seq = $self->seqdb->get_PrimarySeq_by_primary_id($id);
    
    if( defined $seq ) {
	my $servant = new Bio::CorbaServer::PrimarySeq('-poa' => $self->poa, 
						'-seq' => $seq);
	my $id = $self->poa->activate_object($servant);
	return $self->poa->id_to_reference ($id);	
    } else {
	throw org::biocorba::seqcore::UnableToProcess
	    ( reason => ref($self)." could not find seq for $id");
    }
}

=head1 Protected PrimarySeqDB  

=head2 _seqdb

 Title   : _seqdb
 Usage   : 
 Function: get/set the underlying seqdb reference
 Example :
 Returns : reference to seqdb object
 Args    : 

=cut

sub _seqdb {
    my ($self,$value) = @_;
    $self->{_seqdb} = $value if ( defined $value);
    return $self->{'_seqdb'};
}


1;
