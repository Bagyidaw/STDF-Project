#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'STDF::Record' ) || print "Bail out!\n";
}

diag( "Testing STDF::Record $STDF::Record::VERSION, Perl $], $^X" );
