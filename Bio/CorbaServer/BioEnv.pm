# $Id$
#
# BioPerl module for Bio::CorbaServer::BioEnv
#
# Cared for by Ewan Birney <birney@ebi.ac.uk>
#
# Copyright Ewan Birney
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::CorbaServer::BioEnv - A biocorba factory for PrimarySeq, Seq, and
SeqDB objects.

=head1 SYNOPSIS


=head1 DESCRIPTION

This object handles bootstrapping into the biocorba system

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
 the bugs and their resolution.  Bug reports can be submitted via
 email or the web:

  bioperl-bugs@bio.perl.org
  http://bio.perl.org/bioperl-bugs/

=head1 AUTHOR - Ewan Birney, Jason Stajich

Email birney@ebi.ac.uk
      jason@chg.mc.duke.edu

=head1 APPENDIX

The rest of the documentation details each of the object
methods. Internal methods are usually preceded with a _

=cut

# Let the code begin...

package Bio::CorbaServer::BioEnv;
use vars qw($AUTOLOAD $DEBUG @ISA);
use strict;

use Bio::SeqIO;
use Bio::CorbaServer::PrimarySeq;
use Bio::CorbaServer::Seq;
use Bio::CorbaServer::Base;
use Bio::CorbaServer::PrimarySeqIterator;

$DEBUG = 1;
@ISA = qw( POA_org::biocorba::seqcore::BioEnv Bio::CorbaServer::Base);


sub new {
    my ($class, @args) = @_;
    my $self = $class->SUPER::new(@args);
    $self->{'_seqdbs'} = {};
    return $self;
}

=head2 get_PrimarySeq_from_file

 Title   : get_PrimarySeq_from_file
 Usage   : my $iteratory = $bioenv->get_PrimarySeq_from_file($format,
							     $file);
 Function: creates a PrimarySeq from the first sequence in flatfile requested
 Returns : Bio::CorbaServer::PrimarySeq
 Args    : format   - sequence file format (string)
           file     - filename containing sequence (string)

=cut

sub get_PrimarySeq_from_file {
    my ($self,$format,$file) = @_;

    print STDERR "Got [$self][$format][$file]\n" if($DEBUG);
    my $seq;

    eval {
	my $seqio;
	if( $format !~ /\w/ ) {
	    $seqio = Bio::SeqIO->new(-file => $file);
	} else {
	    $seqio = Bio::SeqIO->new(-format => $format,-file => $file);
	} 
	$seq = $seqio->next_primary_seq();
	print "seq is ", $seq->display_id, " ", $seq->seq, "\n";
    };

    if( $@ ) {
	print STDERR "Got exception $@\n" if( $DEBUG);
	throw org::biocorba::seqcore::UnableToProcess 
	    reason => 'Could not load the file or file format.';
	# set exception
    } else {
	my $servant = Bio::CorbaServer::PrimarySeq->new('-poa' => $self->poa, 
							'-seq' => $seq);

	return $servant->get_activated_object_reference();
    }
    die ("should never have got here!");
}

=head2 get_PrimarySeqIterator_from_file

 Title   : get_PrimarySeqIterator_from_file
 Usage   : my $iteratory = $bioenv->get_PrimarySeqIterator_from_file($format,
								     $file);
 Function: creates a PrimarySeqIterator for a flatfile containing sequence(s)
 Returns : Bio::CorbaServer::PrimarySeqIterator
 Args    : format   - sequence file format (string)
           file     - filename containing sequence(s) (string)

=cut

sub get_PrimarySeqIterator_from_file {
    my ($self,$format,$file) = @_;
    
    my $seqio;
    eval {
        # if no format was passed, we just need to guess
        if ($format !~ /\w/) {
            $seqio = Bio::SeqIO->new(-file => $file);
        } else {
            $seqio = Bio::SeqIO->new(-format => $format, -file => $file);
        }
    };
    
    if ($@) {
        throw org::biocorba::seqcore::UnableToProcess 
		  reason => 'Could not load the file or file format.';
    } else {
        my $servant = Bio::CorbaServer::PrimarySeqIterator->new
	    ('-poa' => $self->poa,
	     '-seqio' => $seqio
	     );
	return $servant->get_activated_object_reference;
    }    
    die("Bad place to be.");
}

=head2 get_Seq_from_file

 Title   : get_Seq_from_file
 Usage   : my $iteratory = $bioenv->get_Seq_from_file($format,$file);
 Function: creates a Seq from the first sequence in flatfile requested
 Returns : Bio::CorbaServer::Seq
 Args    : format   - sequence file format (string)
           file     - filename containing sequence (string)

=cut

sub get_Seq_from_file {
    my ($self,$format,$file) = @_;

    print STDERR "Got [$self][$format][$file]\n" if($DEBUG);
    my $seq;

    eval {
	my $seqio;
	if( $format !~ /\w/ ) {
	    $seqio = Bio::SeqIO->new(-file => $file);
	} else {
	    $seqio = Bio::SeqIO->new(-format => $format,-file => $file);
	} 
	$seq = $seqio->next_seq();
    };

    if( $@ ) {
	print STDERR "Got exception $@\n" if( $DEBUG);
	throw org::biocorba::seqcore::UnableToProcess 
	    reason => 'Could not load the file or file format.';
	# set exception
    } else {
	my $servant = Bio::CorbaServer::Seq->new('-poa' => $self->poa, 
						 '-seq' => $seq);
	return $servant->get_activated_object_reference;
    }
    die ("should never have got here!");
}


=head2 get_SeqDB_names

 Title   : get_SeqDB_names
 Usage   : my @names = $bioenv->get_SeqDB_names()
 Function: returns the list of the names of databases available
 Returns : list of strings
 Args    : none

=cut

sub get_SeqDB_names {
    my ($self ) = @_;
    return [ keys %{$self->{'_seqdbs'}}];
}

=head2 get_SeqDB_versions

 Title   : get_SeqDB_versions
 Usage   : my $version = $bioenv->get_SeqDB_versions($dbname)
 Function: returns the list of available versions of a database with
           the given name
 Returns : array of versions (long)
 Args    : name of database (string)

=cut

sub get_SeqDB_versions {
    my ($self, $dbname) = @_;

    my $seqdbhead = $self->{'_seqdbs'}->{$dbname};
    if( !defined $seqdbhead ) {
	throw org::biocorba::seqcore::DoesNotExist 
	    reason => "$dbname is not a known database name.";	
    }
    return [keys %{$seqdbhead}];
}

=head2 get_SeqDB_by_name

 Title   : get_SeqDB_by_name
 Usage   : my $version = $bioenv->get_SeqDB_by_name($dbname,$version)
 Function: returns the stored SeqDB with the given name and version 
 Returns : Bio::CorbaServer::SeqDB
 Args    : database name(string)
           database version (long)

=cut

sub get_SeqDB_by_name {
    my ($self, $dbname,$version) = @_;

    my $seqdbhead = $self->{'_seqdbs'}->{$dbname};
    if( !defined $seqdbhead ) {
	throw org::biocorba::seqcore::DoesNotExist 
	    reason => "$dbname is not a known database name.";	
    }
    my $seqdb = $seqdbhead->{$version};
    if( !defined $seqdb ) {
	throw org::biocorba::seqcore::DoesNotExist 
	    reason => "$dbname ($version) is not a known database version.";	
    }
    return $seqdb->get_activated_object_reference;
}

1;
