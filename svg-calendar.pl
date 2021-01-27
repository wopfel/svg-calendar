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
      .person_holiday_bs {
          fill: rgb(150, 255, 150);
      }
      .person_holiday_th {
          fill: rgb(150, 150, 255);
      }
    ]]>
  </style>
";

my @month_text = qw/ Jan Feb Mär Apr Mai Jun Jul Aug Sep Okt Nov Dez /;
my @dayofweek_text = qw/ So Mo Di Mi Do Fr Sa /;

# Highlight days
# Format: yyyy-mm-dd => #rgb
my %highlight_days = ( "2021-01-27" => "fill:rgb(255,200,200);",
                       "2021-12-24" => "fill:rgb(200,200,255); stroke-width:1; stroke:rgb(0,0,0);",
                     );

# Person's holidays
# Format: name or id => from - to (yyyy-mm-dd)
my %persons_holidays = ( "bs" => "2021-02-24 - 2021-03-03",
                         "th" => "2021-05-03 - 2021-05-05",
                       );

my %persons_holidays_table;
for my $person ( keys %persons_holidays ) {
    my $from_to = $persons_holidays{$person};
    my ( $from, $to ) = $from_to =~ /^(....-..-..) - (....-..-..)$/;
    my ( $y, $m, $d );
    ( $y, $m, $d ) = $from =~ /^(....)-(..)-(..)$/;
    my $unix_ts;
    $unix_ts = POSIX::mktime( 0, 0, 0, $d, $m-1, $y-1900 );
    my $dayofyear_begin = (localtime( $unix_ts ))[7];
    ( $y, $m, $d ) = $to =~ /^(....)-(..)-(..)$/;
    $unix_ts = POSIX::mktime( 0, 0, 0, $d, $m-1, $y-1900 );
    my $dayofyear_end = (localtime( $unix_ts ))[7];
    die if $dayofyear_end < $dayofyear_begin;
    for ( $dayofyear_begin .. $dayofyear_end ) {
        $persons_holidays_table{$person}[$_] = 1;
    }

}

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
        my $line_gap_w = 5;
        # Calculate day properties
        my $unix_ts = POSIX::mktime( 0, 0, 0,  $day, $month-1, $year-1900 );
        my $dayofweek = (localtime( $unix_ts ))[6];
        my $dayofyear = (localtime( $unix_ts ))[7];

        # Hightlight day?
        my $ymd = sprintf "%04d-%02d-%02d", $year, $month, $day;
        if ( exists $highlight_days{$ymd} ) {
            printf "<rect x='%d' y='%d' width='%d' height='%d' style='%s' />\n",
                    $start_month_col_x, $day_y - 25 + 5 + 1,
                    $month_w-$line_gap_w, 25 - 2,
                    $highlight_days{$ymd};
        }

        # Check person's holidays
        for my $person ( keys %persons_holidays_table ) {
            if ( $persons_holidays_table{ $person }[$dayofyear] ) {
                printf "<rect class='person_holiday_$person' x='%d' y='%d' width='%d' height='%d' />\n",
                        $start_month_col_x, $day_y - 25 + 5 + 1,
                        $month_w-$line_gap_w, 25 - 2;

            }
        }

        # Day (1, 2, ...)
        printf "<text x='%d' y='%d'>%d</text>\n", $start_month_col_x, $day_y, $day;
        # Day of week
        printf "<text class='nameofday dayofweek%d' x='%d' y='%d'>%s</text>\n", $dayofweek, $start_month_col_x + 25, $day_y, $dayofweek_text[$dayofweek];
        # Line below a cell
        printf "<line x1='%d' y1='%d' x2='%d' y2='%d' />\n", $start_month_col_x, $day_y+5, $start_month_col_x + $month_w - $line_gap_w, $day_y+5;

    }
}
print "</svg>\n";
