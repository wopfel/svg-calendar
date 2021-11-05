# Part of https://github.com/wopfel/svg-calendar

use strict;
use warnings;
use Test::More;

plan tests => 4;

my $output;
my @output;

my $holidays_matched;

### 2021

@output = `perl ./svg-calendar.pl -year 2021 -holidays holidays.yml 2>&1`;
is( $?, 0, "Good return code." );

chomp @output;

# Count holiday days
$holidays_matched = scalar grep m{<text class='nameofday dayofweek\d holiday' x='\d+' y='\d+'>[[:alnum:]]+</text>}, @output;
cmp_ok( $holidays_matched, '==', 14, "Year 2021 should have 14 holiday days" );

### 2022

@output = `perl ./svg-calendar.pl -year 2022 -holidays holidays.yml 2>&1`;
is( $?, 0, "Good return code." );

chomp @output;

# Count holiday days
$holidays_matched = scalar grep m{<text class='nameofday dayofweek\d holiday' x='\d+' y='\d+'>[[:alnum:]]+</text>}, @output;
cmp_ok( $holidays_matched, '==', 14, "Year 2022 should have 14 holiday days" );
