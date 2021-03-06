#!/usr/bin/perl -w

use strict;
use warnings;

use Test::Harness;
use Cwd ('abs_path');

my $debug = shift;

if ( $debug ) {
   $ENV{'DEBUG_CLASS'} = $debug;
   $Test::Harness::switches = '-w -d';
}


# my $dir = shift || '.';
my $dir = abs_path('.');

unshift @INC, "$dir/libs";
unshift @INC, "$dir/tests";
$ENV{'PATH'} = "$dir/bin:" . ($ENV{'PATH'}||'');
$ENV{'PERLLIB'} = "$dir/libs:" . ($ENV{'PERLLIB'}||'');

$ENV{'BASE_TEST_DIR'} = "$dir/tests";

my $file = shift;

if ( $file ) {
   runtests($file);
   exit;
}

my @files = `find $dir/tests -name '*.t'`;
chomp @files;

runtests(sort @files);
