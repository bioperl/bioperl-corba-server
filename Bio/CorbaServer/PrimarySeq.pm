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


package Bio::CorbaServer::PrimarySeq;

use vars qw($AUTOLOAD @ISA);
use strict;
use Bio::Range;

use Bio::CorbaServer::AnonymousSeq;

@ISA = qw(POA_org::biocorba::seqcore::PrimarySeq 
	Bio::CorbaServer::AnonymousSeq );

=head1 AnonymousSeq Methods

=head2 type

 Title   : type
 Usage   : my $type = $self->type();
 Function: Return the type of the biological sequence, e.g. PROTEIN,
	   RNA, DNA,
 Returns : type [ PROTEIN, RNA, DNA]
 Args    : [optional] type to set for this sequence

=cut

=head2 is_circular

 Title   : is_circular
 Usage   : $obj->is_circular()
 Function: Return whether the biological sequence is circular or linear
 Example :
 Returns : boolean
 Args    : value to set (non zero is true)

=cut

=head2 length

 Title   : length
 Usage   : my $len = $obj->length
 Function: returns length of biological sequence
 Returns : long
 Args    : none

=cut

=head2 seq

 Title   : seq
 Usage   : my $seqstr = $obj->seq
 Function: biological sequence as a string
 Returns : string representing sequence contained
 Args    : none

=cut

=head2 subseq

 Title   : subseq
 Usage   : $self->subseq($begin,$end)
 Function: obtains a subsequence of the biological sequence as a string
 Returns : subseq of sequence beginning at start finishing at end
 Args    : start - start point of substring to obtain (sequence start at 1)
           end   - end point of substring to obtain
=cut

=head1 PrimarySeq Methods

PrimarySeq interface methods implemented

=head2 version

 Title   : version
 Usage   : my $version = $obj->version
 Function: obtain the sequence version
 Returns : long representing the sequence version (0 if no version) 
 Args    : none

=cut

sub version {
    my ($self) = @_;    
    return $self->_version;
}

=head2 display_id

 Title   : display_id
 Usage   : $seq->display_id
 Function:
 Returns : display id for sequence
 Args    : none

=cut

sub display_id {
    my $self = shift;
    my $str = $self->_seq->display_id;
    return $str;
}

=head2 accession_number

 Title   : accession_number
 Usage   : $seq->accession_number
 Function:
 Returns : accession number for sequence
 Args    : none

=cut

sub accession_number {
    my $self = shift;
    my $str = $self->_seq->accession_number();
    return $str;
}

=head2 primary_id

 Title   : primary_id
 Usage   : $seq->primary_id
 Function:
 Returns : primary id of sequence
 Args    : none

=cut

sub primary_id {
    my $self = shift;
    my $str = $self->_seq->primary_id();
    if( $str =~ /hash\((0x[0-9a-f]+)\)/i ) {
	$str = $1;
    } 
    return hex($str);
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

=head1 _version

 Title   : _version
 Usage   : get/set version
 Function: if seq object is a RichSeqI it has a seq_version method so
           seq_version is used if possible otherwise revert to locally 
           stored value.
    
 Example : $self->_version($newversion)
 Returns : version string
 Args    : version to set

=cut

sub _version {
    my ($self,$value) = @_;
    if( $self->_seq->can('seq_version') ) {
	return $self->_seq->seq_version($value);
    }
    if( defined $value || ! defined $self->{'_version'}) {
	$self->{'_version'} = 0 if( !defined $value );
	$self->{'_version'} = $value;
    }    
    return $self->{'_version'};
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

   return 10000;
}


1;
