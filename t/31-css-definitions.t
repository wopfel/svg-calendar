# Part of https://github.com/wopfel/svg-calendar

use strict;
use warnings;
use Test::More;

plan tests => 2 ;

my $output;
my @output;

my $css_matched;

@output = `perl ./svg-calendar.pl 2>&1`;
is( $?, 0, "Good return code." );

chomp @output;

# Count CSS lines
$css_matched = scalar grep m{<\?xml-stylesheet type="text/css" href=".*\.css" \?>}, @output;
cmp_ok( $css_matched, '==', 2, "2 lines having stylesheet refs" );
