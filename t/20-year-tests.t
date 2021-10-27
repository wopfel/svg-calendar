# Part of https://github.com/wopfel/svg-calendar

use strict;
use warnings;
use Test::More;

plan tests => 2;

my $output;
my @output;

@output = `perl ./svg-calendar.pl -year 2021 2>&1`;
is( $?, 0, "Good return code." );

chomp @output;

# March / März: . doesn't match ä
my $months_matched = scalar grep m{<text class='monthname' x='\d+' y='\d+'>(...|Mär)</text>}, @output;
is( $months_matched, 12, "Find 12 months" );
