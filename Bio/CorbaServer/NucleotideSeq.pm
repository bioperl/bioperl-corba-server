# $Id$
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
    
  my $seqio = Bio::SeqIO->new( -format => 'embl' , -file => 'some/file');
  my $seq   = $seqio->next_seq();

  $corbaseq = Bio::CorbaServer::Seq->new($poa,$seq);
  $poa->activate_object($corbaseq);
   # ready to rock and roll.
   
=head1 DESCRIPTION

This provides a CORBA wrapping over a Seq object

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
 the bugs and their resolution.
 Bug reports can be submitted via email or the web:

  bioperl-bugs@bio.perl.org
  http://bio.perl.org/bioperl-bugs/

=head1 AUTHOR - Ewan Birney, Jason Stajich

Email: birney@ebi.ac.uk
       jason@bioperl.org

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
use Bio::CorbaServer::SeqFeatureCollection;
use Bio::CorbaServer::Utils qw( create_Bioperl_location_from_BSANE_location
				create_BSANE_location_from_Bioperl_location);
#use Bio::CorbaServer::AnnotationCollection;

@ISA = qw( POA_bsane::seqcore::NucleotideSequence 
	 Bio::CorbaServer::Seq  );

=head2 NucleotideSequence methods

=head2 reverse_complement

 Title   : reverse_complement
 Usage   : my $revcomstr = $obj->reverse_complement;
 Function: Retrieves a reverse complement for a DNA or RNA sequence 
 Returns : string
 Args    : none

=cut

sub reverse_complement{
   my ($self) = @_;   
   return $self->_seq->revcom->seq();
}

=head2 reverse_complement_interval

 Title   : reverse_complement_interval
 Usage   : my $revcomstr = $obj->reverse_complement_interval($region);
 Function: Retrieves a reverse complement for a DNA or RNA section of sequence 
           defined by sequence region $region 
 Returns : string
 Args    : CorbaServer::SeqFeatureLocation 

=cut

sub reverse_complement_interval{
   my ($self,$bsanelocation) = @_;   
   my $location = create_Bioperl_location_from_BSANE_location($bsanelocation);
   return $self->_seq->subseq($location->start, $location->end)->revcom->seq();
}

=head2 translate_seq

 Title   : translate_seq
 Usage   : my $translated = $seq->translate_seq($frame,$stop_locations)
 Function: Returns the translated sequence for a given sequence and 
           reading frame with specified stop locations
 Returns : protein string
 Args    : frame     => reading frame, must be 0,1,2
           locations => array ref of stop locations (long)
=cut

sub translate_seq {

   my ($self,$frame,$stoplocs) = @_;
   if(  $frame < 0 && $frame > 2 ) { 
       throw bsane::seqcore::ReadingFrameInvalid('reason' => "Reading frame $frame is invalid");
   }
   # FIXME: have not dealt with stop locations yet

   my $seq;
   eval { 
       $seq = $self->_seq->translate(undef,undef,$frame,undef,undef,0);
   };
   if( $@ ) {
       throw bsane::seqcore::ReadingFrameInvalid('reason' => $@);
   }
   return $seq->seq();
}

=head2 translate_seq_region

 Title   : translate_seq_region
 Usage   : my $translated = $seq->translate_seq($region,$stop_locations)
 Function: Returns the translated sequence for a given sequence in a 
           given region with specified stop locations
 Returns : protein string
 Args    : $region   => SeqFeatureLocation
           locations => array ref of stop locations (long)
=cut

sub translate_seq {
   my ($self,$region,$stoplocs) = @_;
   my $location = create_Bioperl_location_from_BSANE_location($region);
   # FIXME: have not dealt with stop locations yet
   my $len = $self->_seq->length;
   if( $location->end > $location->start ) { 
       throw bsane::seqcore::SeqFeatureLocationInvalid( 'reason' => sprintf("End is < Start locations are (%d, %d)", $location->start, $location->end)); 
   }
   if( $location->start > $len || 
       $location->end   > $len ) {
       throw bsane::OutOfBounds( 'reason' => sprintf("Location %d -> %d is not within bound of seq of length %d", $location->start, $location->end, $len) );
   }
   my $seq;
   eval { 
       $seq = $self->_seq->subseq($location->start,$location->end);
       $seq = $seq->translate(undef,undef,undef,undef,undef,0);
   };
   if( $@ ) {
       throw bsane::seqcore::ReadingFrameInvalid('reason' => $@);
   }
   return $seq->seq();
}

=head2 BioSequence methods

=head2 get_anonymous_sequence

 Title   : get_anonymous_sequence
 Usage   : my $seq = $obj->get_anonymouse_sequence();
 Function: Returns an anonymous sequence for a BioSequence
 Returns : seqcore::AnonymouseSequence
 Args    : none

=cut

=head2 get_seq_features

 Title   : get_seq_features
 Usage   : $collection = $seq->get_seq_features()
 Function: Get a SeqFeatureCollection
 Returns : bsane::seqcore::SeqFeatureCollection
 Args    : none

=cut

=head2 get_annotations

 Title   : get_annotations
 Usage   : $collection = $seq->get_annotations
 Function: Get an AnnotationCollection
 Returns : bsane::AnnotationCollection
 Args    : none

=cut

=head2 get_alphabet

 Title   : get_alphabet
 Usage   :
 Function:
 Example :
 Returns : 
 Args    :

=cut


1;





