# Part of https://github.com/wopfel/svg-calendar

use strict;
use warnings;
use Test::More;

plan tests => 4;

my $output;
my @output;

@output = `perl ./svg-calendar.pl -year 2021 2>&1`;
is( $?, 0, "Good return code." );

chomp @output;

# March / März: . doesn't match ä
my $months_matched = scalar grep m{<text class='monthname' x='\d+' y='\d+'>(...|Mär)</text>}, @output;
is( $months_matched, 12, "Find 12 months" );

# Count weeks
my $weeks_matched = scalar grep m{<text class='weeknumber' x='\d+' y='\d+' text-anchor='end'>\d+</text>}, @output;
cmp_ok( $weeks_matched, '==', 52, "Year 2021 should have 52 weeks" );

# Count days
my $days_matched = scalar grep m{<text class='dayofmonth' x='\d+' y='\d+'>\d+</text>}, @output;
cmp_ok( $days_matched, '==', 365, "Year 2021 should have 365 days" );
