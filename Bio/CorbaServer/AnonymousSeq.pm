# $Id$
#
# BioPerl module for Bio::CorbaServer::AnonymousSeq
#
# Cared for by Ewan Birney <birney@ebi.ac.uk>
#
# Copyright Ewan Birney
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::CorbaServer::AnonymousSeq - AnonymousSeq server bindings

=head1 SYNOPSIS

    # get a Bio::CorbaServer::AnonymousSeq somehow
    my $seqstring = $seq->seq;

=head1 DESCRIPTION

This object represents the binding of the Primary Sequence
object in Bioperl to the BioCorba object. This is pretty
simple as the objects are almost identical

=head1 FEEDBACK

=head2 Mailing Lists

User feedback is an integral part of the evolution of this and other
Bioperl modules. Send your comments and suggestions preferably to one
of the Bioperl mailing lists.  Your participation is much appreciated.

  bioperl-l@bio.perl.org          - General discussion
  http://bio.perl.org/MailList.html             - About the mailing lists

=head2 Reporting Bugs

Report bugs to the Bioperl bug tracking system to help us keep track
the bugs and their resolution.  Bug reports can be submitted via email
or the web:

  bioperl-bugs@bio.perl.org
  http://bio.perl.org/bioperl-bugs/

=head1 AUTHOR - Ewan Birney, Jason Stajich

Email birney@ebi.ac.uk
      jason@chg.mc.duke.edu

=head1 APPENDIX

The rest of the documentation details each of the object methods. Internal methods are usually preceded with a _

=cut


# Let the code begin...

package Bio::CorbaServer::AnonymousSeq;

use vars qw($AUTOLOAD @ISA);
use strict;

use Bio::CorbaServer::Base;

@ISA = qw(POA_org::biocorba::seqcore::AnonymousSeq Bio::CorbaServer::Base );

sub new {
    my ($class, @args) = @_;
    my $self = $class->SUPER::new(@args);
    my ($seq) = $self->_rearrange([qw(SEQ)],@args);

    if( ! defined $seq || !ref $seq || ! $seq->isa('Bio::PrimarySeqI') ) {
	$seq = '' if( !defined $seq );
	$self->throw($class ." got a non sequence [$seq] for server object");
    }
    $self->_seq($seq);
    $self->is_circular(0);
    return $self;
}

=head1 AnonymousSeq Methods

=head2 type

 Title   : type
 Usage   : my $type = $self->type();
 Function: Return the type of the biological sequence, e.g. PROTEIN,
	   RNA, DNA,
 Returns : type [ PROTEIN, RNA, DNA]
 Args    : [optional] type to set for this sequence

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
 Args    : value to set (non zero is true)

=cut

sub is_circular {
    my ($self,$value) = @_;
    if( defined $value ) {
	$self->{'_circular'} = $value;
    }
    return $self->{'_circular'} ? 1 : 0;
}


=head2 length

 Title   : length
 Usage   : my $len = $obj->length
 Function: returns length of biological sequence
 Returns : long
 Args    : none

=cut

sub length {
    my $self = shift;
    return $self->_seq->length();
}


=head2 seq

 Title   : seq
 Usage   : my $seqstr = $obj->seq
 Function: biological sequence as a string
 Returns : string representing sequence contained
 Args    : none

=cut

sub seq {
    my $self = shift;
    my $seqstr = $self->_seq->seq;
    return $seqstr;
}

=head2 subseq

 Title   : subseq
 Usage   : $self->subseq($begin,$end)
 Function: obtains a subsequence of the biological sequence as a string
 Returns : subseq of sequence beginning at start finishing at end
 Args    : start - start point of substring to obtain (sequence start at 1)
           end   - end point of substring to obtain
=cut

sub subseq {
    my ($self,$start,$end) = @_;
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
	#set exception
	throw org::biocorba::seqcore::RequestTooLarge(reason=>"parameters $start, $end were too large", suggested_size=>0);
    } else {
	return $ret;
    }
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
	$self->{'_seqobj'} = $value;
    }
    return $self->{'_seqobj'};
}

1;
