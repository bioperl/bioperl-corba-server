# $Id$
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

    # get a Bio::CorbaServer::PrimarySeq somehow
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

Email birney@ebi.ac.uk
      jason@bioperl.org

=head1 APPENDIX

The rest of the documentation details each of the object methods. Internal methods are usually preceded with a _

=cut


# Let the code begin...


package Bio::CorbaServer::PrimarySeq;

use vars qw(@ISA $MAXSIZE);
use strict;
use Bio::CorbaServer::Base;
$MAXSIZE = 10000;

@ISA = qw( POA_bsane::seqcore::AnonymousSequence Bio::CorbaServer::Base );

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

=head2 get_type

 Title   : get_type
 Usage   : my $type = $self->get_type();
 Function: Return the type of the biological sequence, e.g. PROTEIN,
	   RNA, DNA,
 Returns : type [ PROTEIN, RNA, DNA]
 Args    : [optional] type to set for this sequence

=cut

sub get_type {
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
    return defined $self->{'_circular'} && $self->{'_circular'} ? 1 : 0;
}


=head2 get_length

 Title   : get_length
 Usage   : my $len = $obj->get_length
 Function: returns length of biological sequence
 Returns : long
 Args    : none

=cut

sub get_length {
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

=head2 sub_seq

 Title   : sub_seq
 Usage   : $self->sub_seq($begin,$end)
 Function: obtains a subsequence of the biological sequence as a string
 Returns : subseq of sequence beginning at start finishing at end
 Args    : start - start point of substring to obtain (sequence start at 1)
           end   - end point of substring to obtain
=cut

sub sub_seq {
    my ($self,$start,$end) = @_;
    if( !defined $end || !defined $start || ($end < $start) ) {
	$start = '' if( !defined $start);
	$end = '' if( !defined $end);
	throw bsane::OutOfBounds
	    (reason=>"start is not before end ($start,$end)");
    } elsif( ($end - $start ) > $self->max_request_length ) {
	throw bsane::RequestTooLarge
	    (reason=> ($end-$start) . " is larger than max request length", 
	     suggested_size=>$self->max_request_length);
    } 

    my $seqstr;
    eval {
	$seqstr = $self->_seq->subseq($start,$end);
    };
    if( $@ ) {	
	throw bsane::OutOfRange(reason=>$@);
    } 
    
    return $seqstr;
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

=head2 max_request_length

 Title   : max_request_length
 Usage   :
 Function:
 Example :
 Returns : 
 Args    :

=cut

sub max_request_length{
   my ($self,@args) = @_;

   return 100000;
}

=head2 Identifiable interface

=head2 get_id

 Title   : get_id
 Usage   : my $id = $seq->accession();
 Function: Retrieve a sequence id (accession number)
 Returns : string
 Args    : none


=cut

sub get_id{
   my ($self) = @_;
   return $self->_seq->accession || $self->_seq->display_id();
}

=head2 get_name

 Title   : get_name
 Usage   : my $name = $seq->get_name();
 Function: Retrieves a sequence name
 Returns : string
 Args    : nonex


=cut

sub get_name{
   my ($self) = @_;
   return $self->_seq->display_id();
}

=head2 get_description

 Title   : get_description
 Usage   : my $desc = $seq->get_description();
 Function: Retrieves the description for this sequence
 Returns : string 
 Args    : none


=cut

sub get_description{
   my ($self,@args) = @_;
   return $self->_seq->desc();
}

=head2 get_basis

 Title   : get_basis
 Usage   : my $basis = $seq->get_basis
 Function: Retrieves the basis this sequence is from (always experimental)
 Returns : numeric
 Args    : none


=cut

sub get_basis{
   my ($self) = @_;
   return 1; # 1 is experimental

}

1;
