
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

Bio::CorbaServer::BioEnv - DESCRIPTION of Object

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

=head1 AUTHOR - Ewan Birney

Email birney@ebi.ac.uk

Describe contact details here

=head1 APPENDIX

The rest of the documentation details each of the object methods. Internal methods are usually preceded with a _

=cut


# Let the code begin...


package Bio::CorbaServer::BioEnv;
use vars qw($AUTOLOAD @ISA);
use strict;

use Bio::SeqIO;
use Bio::CorbaServer::PrimarySeq;
use Bio::CorbaServer::Base;
use Bio::CorbaServer::PrimarySeqIterator;

@ISA = qw( Bio::CorbaServer::Base POA_org::biocorba::seqcore::BioEnv);


sub new {
    my ($class, $poa, @args) = @_;
    my $self = Bio::CorbaServer::Base->new($poa, @args);
    bless $self,$class;
    return $self;
}

sub PrimarySeq_from_file {
    my $self = shift;
    my $format = shift;
    my $file = shift;

    print STDERR "Got [$self][$format][$file]\n";
    my $seq;


    eval {
	my $seqio;
	if( $format !~ /\w/ ) {
	    $seqio = Bio::SeqIO->new(-file => $file);
	} else {
	    $seqio = Bio::SeqIO->new(-format => $format,-file => $file);
	} 
	$seq = $seqio->next_primary_seq();
    };

    if( $@ ) {
	print STDERR "Got exception $@\n";
	# set exception
    } else {
	my $servant = Bio::CorbaServer::PrimarySeq->new($self->poa, $seq);
	print STDERR "Got a ",ref($servant),"... about to activate...\n";
	my $id = $self->poa->activate_object ($servant);
	
        # seg faults if I don't touch id. Yikes
	my $other = $id;
	print STDERR "Got id $id - $other\n";
	my $temp = $self->poa->id_to_reference($id);
	
	print STDERR "About to return servant\n";	
	return $temp;
    }

    die ("should never have got here!");
}

sub PrimarySeqIterator_from_file {
    my $self = shift;
    my $format = shift;
    my $file = shift;
    
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
        my $servant = Bio::CorbaServer::PrimarySeqIterator->new($self->poa, 
          $seqio);
        my $id = $self->poa->activate_object($servant);
        my $object = $self->poa->id_to_reference($id);
        
        return $object;
    }
    
    die("Bad place to be.");
}

		
		


