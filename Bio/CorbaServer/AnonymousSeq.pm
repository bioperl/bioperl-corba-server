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
      jason@chg.mc.duke.edu

=head1 APPENDIX

The rest of the documentation details each of the object methods. Internal methods are usually preceded with a _

=cut

# Let the code begin...

package Bio::CorbaServer::AnonymousSeq;

use vars qw($AUTOLOAD @ISA);
use strict;

use Bio::CorbaServer::Base;

@ISA = qw( POA_org::biocorba::seqcore::AnonymousSeq Bio::CorbaServer::Base );


1;
