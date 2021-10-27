# Part of https://github.com/wopfel/svg-calendar

use strict;
use warnings;
use Test::More;

plan tests => 2;

my $output;

$output = `perl -c ./svg-calendar.pl 2>&1`;

is( $?, 0, "Good return code." );
ok( $output eq "./svg-calendar.pl syntax OK\n", "Syntax okay." );
