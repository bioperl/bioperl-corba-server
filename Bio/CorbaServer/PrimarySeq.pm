
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

  vsns-bcd-perl@lists.uni-bielefeld.de          - General discussion
  vsns-bcd-perl-guts@lists.uni-bielefeld.de     - Technically-oriented discussion
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
use Bio::CorbaServer::Base;
use strict;

# Object preamble - inherits from Bio::Root::Object




@ISA = qw(Bio::CorbaServer::Base POA_org::Biocorba::Seqcore::PrimarySeq);

sub new {
    my $class = shift;
    my $poa = shift;
    my $seq = shift;

    if( ! defined $seq || !ref $seq || !$seq->isa('Bio::PrimarySeqI') ) {
	die "In CorbaServer PrimarySeq, got a non sequence [$seq] for server object";
    }

    my $self = Bio::CorbaServer::Base->new($poa);

    $self->{'seqobj'} = $seq;
    bless $self,$class;
    return $self;
}

sub length {
    my $self = shift;
    return $self->{'seqobj'}->length;
}

sub get_seq {
    my $self = shift;
    my $seqstr = $self->{'seqobj'}->seq;
    return $seqstr;
}

sub get_subseq {
    my $self = shift;
    my $s = shift;
    my $e = shift;
    if( !defined $e ) {
	die "Someone managed to call get_subseq with no end";
    }

    my $ret;
    eval {
	$self->{'seqobj'}->subseq($s,$e);
    };
    if( $@ ) {
	#set exception
    } else {
	return $ret;
    }

}

sub display_id {
    my $self = shift;
    return $self->{'seqobj'}->display_id();
}

sub accession_number {
    my $self = shift;
    return $self->{'seqobj'}->accession_number();
}

sub primary_id {
    my $self = shift;
    return $self->{'seqobj'}->primary_id();
}

sub max_request_length {
    my $self = shift;
    return 100000;
}

1;


	    

