
#
# BioPerl module for Bio::CorbaServer::Seq
#
# Cared for by Ewan Birney <birney@ebi.ac.uk>
#
# Copyright Ewan Birney
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::CorbaServer::Seq - CORBA wrapper around a Seq Object

=head1 SYNOPSIS

  $seqio = Bio::SeqIO->new( -format => 'embl' , -file => 'some/file');
  $seq   = $seqio->next_seq();

  $corbaseq = Bio::CorbaServer::Seq->new($poa,$seq);
  $poa->activate_object($corbaseq);
   # ready to rock and roll.


=head1 DESCRIPTION

This provides a CORBA wrapping over a Seq object

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

Describe contact details here

=head1 APPENDIX

The rest of the documentation details each of the object methods. Internal methods are usually preceded with a _

=cut


# Let the code begin...


package Bio::CorbaServer::Seq;
use vars qw(@ISA);
use strict;


use Bio::CorbaServer::PrimarySeq;
use Bio::CorbaServer::Base;

@ISA = qw(Bio::CorbaServer::Base POA_org::Biocorba::Seqcore::Seq);


sub new {
    my $class = shift;
    my $poa = shift;
    my $seq = shift;

    my $self = Bio::CorbaServer::Base->new($poa);

    if( ! defined $seq ) {
	die "Must have poa and seq into Seq";
    }
    bless $self,$class;

    $self->seq($seq);
    return $self;
}

=head1 PrimarySeq functions

These functions are here because Seq inheriets from PrimarySeq
object

=cut

sub length {
    my $self = shift;
    return $self->seq->length;
}

sub get_seq {
    my $self = shift;
    my $seqstr = $self->seq->seq;
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
	$self->seq->subseq($s,$e);
    };
    if( $@ ) {
	#set exception
    } else {
	return $ret;
    }

}

sub display_id {
    my $self = shift;
    return $self->seq->display_id();
}

sub accession_number {
    my $self = shift;
    return $self->seq->accession_number();
}

sub primary_id {
    my $self = shift;
    return $self->seq->primary_id();
}

sub max_request_length {
    my $self = shift;
    return 100000;
}

=head1 Seq functions

These are the key Seq functions

=cut

sub all_features {
    my $self = shift;
    my @sf;
    my @ret;

    @sf = $self->seq->top_SeqFeatures();
    
    foreach my $sf ( @sf ) {
	my $serv = Bio::CorbaServer::SeqFeature->new($self->poa,$sf);
	my $id = $self->poa->activate_object ($serv);
	my $temp = $self->poa->id_to_reference ($id);
	push(@ret,$temp);
    }

    return @ret;
}

sub all_features_iterator {
    my $self = shift;
    my @corbarefs = $self->all_features;

    return Bio::CorbaServer::SeqFeatureIterator->new($self->poa,\@corbarefs);
}

sub features_region {

}

sub features_region_iterator {

}

sub max_feature_request {
    return 100000;
}

sub get_PrimarySeq {

}




=head2 seq

 Title   : seq
 Usage   : $obj->seq($newval)
 Function: 
 Example : 
 Returns : value of seq
 Args    : newvalue (optional)


=cut

sub seq{
   my ($obj,$value) = @_;
   if( defined $value) {
      $obj->{'seq'} = $value;
    }
    return $obj->{'seq'};

}







