
#
# BioPerl module for Bio::CorbaServer::SeqFeatureIterator
#
# Cared for by Ewan Birney <birney@ebi.ac.uk>
#
# Copyright Ewan Birney
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::CorbaServer::SeqFeatureIterator - CORBA wrapper around a SeqFeatureIterator 

=head1 SYNOPSIS


=head1 DESCRIPTION

This provides a CORBA wrapping over a SeqFeatureIterator object

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


package Bio::CorbaServer::SeqFeatureIterator;
use vars qw(@ISA);
use strict;
use Bio::CorbaServer::Base;


@ISA = qw(Bio::CorbaServer::Base POA_org::Biocorba::Seqcore::SeqFeatureIterator);


sub new {
    my $class = shift;
    my $poa = shift;
    my $array = shift;

    my $self = Bio::CorbaServer::Base->new($poa);

    if( ! defined $array ) {
	die "Must have poa and seq into Seq";
    }
    bless $self,$class;

    $self->{'array'} = $array;
    return $self;
}

sub next {
    my $self = shift;

    if( $#{$self->{'array'}} >= 0 ) {
	return shift @{$self->{'array'}};
    } else {
	throw org::Biocorba::Seqcore::EndOfStream;
    }
}

sub next {
    my $self = shift;

    if( $#{$self->{'array'}} >= 0 ) {
	return 1;
    } else {
	return 0;
    }
}


    