# $Id$
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

    # get a Bio::CorbaServer::SeqDB from a corbaserver

    # it is a PrimarySeqDB so can call PrimarySeqDB methods
    my $dbname = $db->name;
    my $version = $db->version;
    my $maxseqlen = $db->max_sequence_length();
    try { 
	my $seq = $db->get_PrimarySeq('AC002010.1');
    } catch bsane::seqcore::UnableToProcess with { 
	my $e = shift;
	print STDERR "trouble processing accession 'AC002010.1', error was : ",
	$e->{reason}, "\n";
    }
    my $pseqvec = $db->get_PrimarySeqVector;
    my $iter = $pseqvec->iterator();
    while( $iter->has_more() ) {
	my $seq = $iter->next();
	print "seq is ", $seq->display_id(), "\n";
    }

    # SeqDB specific methods
    try { 
	# get a Seq with Features
	my $seq = $db->resolve('AC002010');
    } catch bsane::seqcore::UnableToProcess with { 
	my $e = shift;
	print STDERR "trouble processing accession 'AC002010.1', error was : ",
	$e->{reason}, "\n";
    }
  

=head1 DESCRIPTION


This object handles represenatation of Sequence Database.  It has a
reference to a Bio::DB::SeqI and maps biocorba methods to the
Bio::DB::SeqI object.  This object inherits from
Bio::CorbaServer::PrimarySeqDB, an implements 2 additional methods.
get_Seq obtains a Bio::CorbaServer::Seq object which could contain
Sequence Features.  The method accession_numbers returns a list of all
the primary Accession Numbers of the sequences contained within this
database.

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
the bugs and their resolution.  Bug reports can be submitted via email
or the web:

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
use vars qw(@ISA);
use strict;

# Object preamble - inherits from Bio::CorbaServer::Base
use Bio::CorbaServer::Base;
use Bio::CorbaServer::Seq;

@ISA = qw(POA_bsane::collection::BioSequenceCollection 
	Bio::CorbaServer::Base );

sub new {
    my ($class, @args) = @_;
    my $self = $class->SUPER::new(@args);
    my ($seqdb) = $self->_rearrange([qw(SEQDB)],@args);
    if( ! defined $seqdb || !ref $seqdb || 
	! $seqdb->isa('Bio::DB::SeqI') ) {
        $seqdb = '' if( !defined $seqdb );
        $self->throw($class ." got a non sequencedb [$seqdb] for server object");
    }    
    $self->_seqdb($seqdb);
    return $self;
}

=head1 bsane::collection methods

=head1 BioSequenceIdentifierResolver interface

=head2 resolve

 Title   : resolve
 Usage   : $seq = $obj->resolve($id)
 Function: Returns a BioSequence for a given id
 Returns : seqcore::BioSequence
 Args    : string -> identifier

=cut

sub resolve{
   my ($self,$id) = @_;
   my $seq = $self->_seqdb->get_Seq_by_acc($id);
   if( ! $seq ) { 
       $seq = $self->_seqdb->get_Seq_by_id($id)
   }
   if( ! $seq ) {
       throw bsane::IdentifierDoesNotExist('id' => $id); 
   }
   my $seqobj = new Bio::CorbaServer::Seq('-seq' => $seq,
					  '-poa' => $self->poa);
   return $seqobj->get_activated_object_reference();
}

=head2 get_seqs

 Title   : get_seqs
 Usage   : my @seqs = $db->get_seqs($howmany, $iterator)
 Function: Returns the list of sequences, 
 Example :
 Returns : 
 Args    :


=cut

sub get_seqs{
   my ($self,$howmany,$iterator) = @_;
   # this better be an index handle
   if(! $self->_seqdb->isa('Bio::Index::Abstract') ) {
       throw bsane::OutOfBounds('reason' => 'cannot call get_seqs on a non Indexed database');
   }
   
   my $list = [];
   my $seqio = $self->_seqdb->get_PrimarySeq_stream();
   my $count = 0;
   while( $count++ < $howmany && defined (my $s = $seqio->next_seq) ) {
       my $sobj = new Bio::CorbaServer::Seq('-poa' => $self->poa,
					    '-seq' => $s);
       push @$list, $sobj->get_activated_object_reference();
   }
   $iterator = new Bio::CorbaServer::SeqIterator('-poa' => $self->poa,
						 '-seqio' => $seqio);
      
   return $list;
}


=head2 bsane::Annotatable methods

=head2 get_annotations

 Title   : get_annotations
 Usage   : my @annotations = $db->get_annotations()
 Function: Get the annotations associated with this object?
 Returns : List of annotations
 Args    : none


=cut

sub get_annotations{
   my ($self) = @_;
   throw bsane::IllegalSymbolException('reason' => 'The get_annotations method is not implemented by the bioperl biocorba implementation');
}

=head2 _seqdb

 Title   : _seqdb
 Usage   : $obj->_seqdb($newval)
 Function: 
 Example : 
 Returns : value of _seqdb
 Args    : newvalue (optional)


=cut

sub _seqdb{
   my ($self,$value) = @_;
   if( defined $value) {
      $self->{'_seqdb'} = $value;
    }
    return $self->{'_seqdb'};

}

1;


