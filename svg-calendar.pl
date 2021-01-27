#!/bin/perl

use strict;
use warnings;
use POSIX;


my $year = 2021;

print '<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
';

print '<svg height="1000" width="1400" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" xml:space="preserve" xmlns:serif="http://www.serif.com/" style="fill-rule:evenodd;clip-rule:evenodd;stroke-linecap:round;stroke-linejoin:round;stroke-miterlimit:1.5;">
';

print "  <style type='text/css'>
    <![CDATA[
      text {
        font-family: Verdana, Arial, Helvetica, sans-serif;
      }
      text.monthname {
          font-size: 150%;
      }
      text.nameofday {
          font-size: 50%;
      }
      text.dayofweek0 {
          fill: red;
      }
      line {
          stroke:rgb(150, 150, 150);
          stroke-width: 1px;
      }
    ]]>
  </style>
";

my @month_text = qw/ Jan Feb Mär Apr Mai Jun Jul Aug Sep Okt Nov Dez /;
my @dayofweek_text = qw/ So Mo Di Mi Do Fr Sa /;

my $start_month_names_y = 25;
my $start_days_of_month_y = $start_month_names_y + 5;
my $month_w = 110;

for my $month ( 1 .. 12 ) {
    my $start_month_col_x = 10+$month_w*($month-1);

    printf "<text class='monthname' x='%d' y='%d'>%s</text>\n", $start_month_col_x, $start_month_names_y, $month_text[$month-1];

    my $days_this_month = 31;
    $days_this_month = 30 if $month==4 or $month==6 or $month==9 or $month==11;
    $days_this_month = 28 if $month==2; #TODO

    for my $day ( 1 .. $days_this_month ) {

        # Calculate positions
        my $day_y = $start_days_of_month_y + 25 * $day;
        # Calculate day properties
        my $unix_ts = POSIX::mktime( 0, 0, 0,  $day, $month-1, $year-1900 );
        my $dayofweek = (localtime( $unix_ts ))[6];

        # Day (1, 2, ...)
        printf "<text x='%d' y='%d'>%d</text>\n", $start_month_col_x, $day_y, $day;
        # Day of week
        printf "<text class='nameofday dayofweek%d' x='%d' y='%d'>%s</text>\n", $dayofweek, $start_month_col_x + 25, $day_y, $dayofweek_text[$dayofweek];
        # Line below a cell
        printf "<line x1='%d' y1='%d' x2='%d' y2='%d' />\n", $start_month_col_x, $day_y+5, $start_month_col_x + $month_w, $day_y+5;

    }
}
print "</svg>\n";
