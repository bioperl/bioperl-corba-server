## --Makefile.PL for Bioperl core module distribution--##
## ----------------------------------------------------##


#
# Basically this is a standard Makefile with a hash of
# needed packages which are tested at the start
#
# If you want help with this Makefile get in touch with
# the bioperl core by sending a message to bioperl-bugs@bio.perl.org
# for real bugs or vsns-bcd-perl-guts@lists.uni-bielefeld.de
# to send a mail to all the bioperl core developpers.
#


%packages = (
	     'CORBA::ORBit' => '0.0/CORBA access/CORBA/Everything',
	     );

sub check_package {
    my ($name,$str) = @_;
    my($ver,$desc,$expl,@modules);

    ($ver,$desc,$expl,$module) = split( /\// , $str);
    if( !eval "require $name") {
	print "External Module $name, $desc,\n is not installed on this computer.\n  The $module in Bioperl needs it for $expl\n\n";
	return 1;
    }

    return 0;
}

#
# Generate sub testing package system
#
#

# make mini test targets for playing around with
# in testing...

opendir(DIR,"t") || warn "No test directory. Weird!";
@files = readdir(DIR);
shift @files;
shift @files;
foreach my $file (@files) {
    $file =~ /(\w+)\.t/ || next;
    $file = $1;
    $line = "test_$file :: pure_all\n\tPERL_DL_NONLAZY=1 \$(FULLPERL) -I\$(INST_ARCHLIB) -I\$(INST_LIB) -I\$(PERL_ARCHLIB) -I\$(PERL_LIB) -e \'use Test::Harness qw(&runtests \$\$verbose); \$\$verbose=\$(TEST_VERBOSE); runtests \@ARGV;\' t/$file.t\n";
    push(@tline,$line);
    push(@targets,$file);
    $tset  .= "$file \\\n";
}

$tline = join('',@tline);
$tline = "show_tests :\n\t\@echo \'type make test_<subtest> to run\'\n\t\@echo '$tset'\n$tline\n";

print STDERR "Generated sub tests. go make show_tests to see available subtests\n";

sub MY::postamble {
             $tline;
           }


				           
#
# Talk to Ewan (<birney@sanger.ac.uk>) for more info.
#

# Let the code begin...

require 5.004;
use ExtUtils::MakeMaker;

$do_autoload_finesse = 0;
$NAME     = 'BioCorbaServer';
$DISTNAME = "bioperl-corba-server";
$VERSION  = "0.6";

$error = 0;
foreach $name ( keys %packages ) {
    if( &check_package($name,$packages{$name}) == 1 ) {
	$error = 1;
    }
}

if( $error == 1 ) {
    print <<QQ_ERROR_QQ;

Warning:

   There are some external packages, listed above, which bioperl-corba-server 
   uses. You will have to install these packages before it works.
   Go to http://www.cpan.org/


QQ_ERROR_QQ
}

WriteMakefile(
    NAME	=> $NAME,
    DISTNAME    => $DISTNAME,
    VERSION     => $VERSION,
    'dist'      => {  COMPRESS     => 'gzip -9f',
                      SUFFIX       => '.gz', 
                      DIST_DEFAULT => 'all tardist',
                   },

   'realclean'  => {  FILES        => join(' ',@BACKUP_FILES) }
);




