
#
# BioPerl module for Bio::CorbaServer::PrimarySeq
#
# Cared for by Ewan Birney <birney@ebi.ac.uk>
#
# Copyright Ewan Birney
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::CorbaServer::PrimarySeq - PrimarySeq server bindings

=head1 SYNOPSIS

Give standard usage here

=head1 DESCRIPTION

This object represents the binding of the Primary Sequence
object in Bioperl to the BioCorba object. This is pretty
simple as the objects are almost identical

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


=head1 APPENDIX

The rest of the documentation details each of the object methods. Internal methods are usually preceded with a _

=cut


# Let the code begin...


package Bio::CorbaServer::PrimarySeq;

use vars qw($AUTOLOAD @ISA);
use strict;

use Bio::CorbaServer::Base;

# Object preamble - inherits from Bio::Root::Object

@ISA = qw(POA_org::biocorba::seqcore::PrimarySeq Bio::CorbaServer::Base);

sub new {
    my ($class, $poa, $seq, @args) = @_;
    
    if( ! defined $seq || !ref $seq || ! $seq->isa('Bio::PrimarySeqI') ) {
	$seq = '' if( !defined $seq );
	throw org::biocorba::seqcore::UnableToProcess 
	    (reason=>$class ." got a non sequence [$seq] for server object");
    }

    my $self = Bio::CorbaServer::Base->new($poa, @args);
    
    bless $self,$class;
    $self->_seq($seq);
    $self->version(0);

    return $self;
}


=head1 AnonymousSeq Methods

Implemented AnonymousSeq Methods

=head2 type

 Title   : type
 Usage   :
 Function:
 Example :
 Returns : 
 Args    :

=cut

sub type {
    my $self = shift;
    my $moltype = uc $self->_seq->moltype;
    if(  $moltype eq 'DNA' ) {
	return 1;
    } elsif ( $moltype eq 'RNA' ) {
	return 2;
    } elsif ( $moltype =~ /PROT/i ) {
	return 0;
    } else { 
	return -1;
    }
}

=head2 is_circular

 Title   : is_circular
 Usage   : $obj->is_circular()
 Function: Return whether the biological sequence is circular or linear
 Example :
 Returns : boolean
 Args    :

=cut

sub is_circular {
    my $self = shift;
    return 0;
}


=head2 length

 Title   : length
 Usage   :
 Function:
 Example :
 Returns : 
 Args    :

=cut

sub length {
    my $self = shift;
    return $self->_seq->length();
}


=head2 seq

 Title   : seq
 Usage   :
 Function:
 Example :
 Returns : string representing sequence contained
 Args    :

=cut

sub seq {
    my $self = shift;
    my $seqstr = $self->_seq->seq;
    return $seqstr;
}

=head2 subseq

 Title   : subseq
 Usage   : $self->subseq($begin,$end)
 Function:
 Example :
 Returns : subseq of sequence beginning at start finishing at end
 Args    :

=cut

sub subseq {
    my $self = shift;
    my $start = shift;
    my $end = shift;
    if( !defined $end || !defined $start || ($end < $start) ) {
	$start = '' if( !defined $start);
	$end = '' if( !defined $end);
	throw org::biocorba::seqcore::OutOfRange
	    (reason=>"start is not before end ($start,$end");
    } elsif( ($end - $start ) > $self->max_request_length ) {
	throw org::biocorba::seqcore::RequestTooLarge
	    (reason=> ($end-$start) . " is larger than max request length", 
	     suggested_size=>$self->max_request_length);
    } 

    my $ret;
    eval {
	$ret = $self->_seq->subseq($start,$end);
    };
    if( $@ ) {
	throw org::biocorba::seqcore::RequestTooLarge

	#set exception
    } else {
	return $ret;
    }
}


=head2 version

 Title   : version
 Usage   :
 Function:
 Example :
 Returns : 
 Args    :

=cut

sub version {
    my ($self,$value) = @_;
    if( defined $value) {
	if( $version =~ /^(\s+)?\d+(\s+)?$/ ) {
	    $self->{_version} = $value;
	} else {
	    throw org::biocorba::seqcore::UnableToProcess( reason => "version must be a number not $value");
	}
    }
    return $self->{_version};
}

=head1 PrimarySeq Methods

PrimarySeq interface methods implemented

=head2 display_id

 Title   : display_id
 Usage   : $seq->display_id
 Function:
 Example :
 Returns : display id for sequence
 Args    :

=cut

sub display_id {
    my $self = shift;
    return $self->_seq->display_id;
}

=head2 accession_number

 Title   : accession_number
 Usage   : $seq->accession_number
 Function:
 Example :
 Returns : accession number for sequence
 Args    :

=cut

sub accession_number {
    my $self = shift;
    return $self->_seq->accession_number();
}

=head2 primary_id

 Title   : primary_id
 Usage   : $seq->primary_id
 Function:
 Example :
 Returns : primary id of sequence
 Args    :

=cut

sub primary_id {
    my $self = shift;
    return $self->_seq->primary_id();
}

=head1 Private Methods

Private Methods local to this module

=head1 _seq

 Title   : _seq
 Usage   : get/set seq reference
 Function:
 Example : $self->_seq($new_seq)
 Returns : reference to underlying contained seq object
 Args    : [optional] new-value

=cut

sub _seq {
    my ($self,$value) = @_;
    if( defined $value) {
	$self->{_seqobj} = $value;
    }
    return $self->{_seqobj};
}

1;


	    

