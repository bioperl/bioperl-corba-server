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
	my $seq = $db->get_PrimarySeq('AC002010', 1);
    } catch org::biocorba::seqcore::UnableToProcess with { 
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
	my $seq = $db->get_Seq('AC002010', 1);
    } catch org::biocorba::seqcore::UnableToProcess with { 
	my $e = shift;
	print STDERR "trouble processing accession 'AC002010.1', error was : ",
	$e->{reason}, "\n";
    }
  
    my @accessions = $db->accession_numbers();

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
use vars qw($AUTOLOAD @ISA);
use strict;

# Object preamble - inherits from Bio::CorbaServer::PrimarySeqDB
use Bio::CorbaServer::PrimarySeqDB;
use Bio::CorbaServer::PrimarySeqIterator;
use Bio::CorbaServer::Seq;

@ISA = qw(POA_org::biocorba::seqcore::SeqDB Bio::CorbaServer::PrimarySeqDB );

# new is defined by PrimarySeqDB

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
    my ($self,$id) = @_;
    print STDERR "Getting $id\n";

    my $seq = $self->_seqdb->get_Seq_by_acc($id);

    if( $seq->accession ne $id) {
	$self->warn("This looks like a problem - asked for $id, got ".$seq->accession);
    }


    if( defined $seq ) {
	# data marshall object out	
	my $servant = Bio::CorbaServer::Seq->new('-poa' => $self->poa, 
						 '-seq' => $seq);
	return $servant->get_activated_object_reference;
    } else {
	throw org::biocorba::seqcore::UnableToProcess
	    ( reason => ref($self)." could not find seq for $id");	
    }
}

=head2 accession_numbers

 Title   : accession_numbers
 Usage   : my @ans = $self->accession_numbers()
 Function:
 Example :
 Returns : reference to array containing strings of all accession numbers in db
 Args    : 

=cut

sub accession_numbers {
    my ($self) = @_;    
    my @ids = $self->_seqdb->get_all_primary_ids();
    return \@ids;
}

1;


