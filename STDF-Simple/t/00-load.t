#!perl -T
use 5.10.0;
use strict;
use warnings;
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'STDF::Simple' ) || print "Bail out!\n";
}

diag( "Testing STDF::Simple $STDF::Simple::VERSION, Perl $], $^X" );
