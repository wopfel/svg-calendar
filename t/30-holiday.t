# Part of https://github.com/wopfel/svg-calendar

use strict;
use warnings;
use Test::More;

plan tests => 2;

my $output;
my @output;

@output = `perl ./svg-calendar.pl -year 2021 -holidays holidays.yml 2>&1`;
is( $?, 0, "Good return code." );

chomp @output;

# Count holiday days
my $holidays_matched = scalar grep m{<text class='nameofday dayofweek\d holiday' x='\d+' y='\d+'>[[:alnum:]]+</text>}, @output;
cmp_ok( $holidays_matched, '==', 4, "Year 2021 should have 4 holiday days" );
