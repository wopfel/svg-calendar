# Part of https://github.com/wopfel/svg-calendar

use strict;
use warnings;
use Test::More;

plan tests => 8;

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

like( join("",@output), qr/>Apr<.*>2<.*class='nameofday dayofweek5 holiday' x='25' y='0'>Fr<.*>3<.*>Mai</, "Holiday on April 2nd" );
unlike( join("",@output), qr/>Apr<.*>15<.*class='nameofday dayofweek5 holiday' x='25' y='0'>Fr<.*>16<.*>Mai</, "No holiday on April 15th" );

### 2022

@output = `perl ./svg-calendar.pl -year 2022 -holidays holidays.yml 2>&1`;
is( $?, 0, "Good return code." );

chomp @output;

# Count holiday days
$holidays_matched = scalar grep m{<text class='nameofday dayofweek\d holiday' x='\d+' y='\d+'>[[:alnum:]]+</text>}, @output;
cmp_ok( $holidays_matched, '==', 14, "Year 2022 should have 14 holiday days" );

unlike( join("",@output), qr/>Apr<.*>2<.*class='nameofday dayofweek5 holiday' x='25' y='0'>Fr<.*>3<.*>Mai</, "No holiday on April 2nd" );
like( join("",@output), qr/>Apr<.*>15<.*class='nameofday dayofweek5 holiday' x='25' y='0'>Fr<.*>16<.*>Mai</, "Holiday on April 15th" );
