# Part of https://github.com/wopfel/svg-calendar

use strict;
use warnings;
use Test::More;

plan tests => 4;

my $output;

$output = `perl ./svg-calendar.pl -thisisanunknownoption 2>&1`;
isnt( $?, 0, "Return code greater 0." );

like( $output, qr/^Unknown option: thisisanunknownoption$/m, "Wrong option shall raise an error" );

##

$output = `perl ./svg-calendar.pl -help 2>&1`;
isnt( $?, 0, "Return code greater 0." );

like( $output, qr/^Usage: perl/m, "Usage written in help text" );
