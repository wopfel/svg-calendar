#!/bin/perl


###################################################################
#
#   svg-calendar
#
###################################################################
#
#   A program which creates a calendar in .svg file format
#
#   https://github.com/wopfel/svg-calendar
#
#   Copyright (c) 2021 Bernd Arnold
#   See LICENSE file for details
#
###################################################################


use strict;
use warnings;
use POSIX;
use Time::Piece;
use YAML::Tiny;

# Local libraries
use lib "./libs/.";
use vacation;


my $year = 2021;

print '<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
';

print '<?xml-stylesheet type="text/css" href="svg-calendar.css" ?>
';

print '<svg height="1000" width="1400" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" xml:space="preserve" xmlns:serif="http://www.serif.com/" style="fill-rule:evenodd;clip-rule:evenodd;stroke-linecap:round;stroke-linejoin:round;stroke-miterlimit:1.5;">
';

my @month_text = qw/ Jan Feb Mär Apr Mai Jun Jul Aug Sep Okt Nov Dez /;
my @dayofweek_text = qw/ So Mo Di Mi Do Fr Sa /;

# Highlight days (also used for notations)
my $highlight_days = YAML::Tiny->read( "highlight_days.yml" );
die "Error in yml file 'highlight_days.yml'"  unless  $highlight_days;

# Holidays
my $holidays = YAML::Tiny->read( "holidays.yml" );
die "Error in yml file 'holidays.yml'"  unless  $holidays;




#
# Vacation
#

vacation::load( $year );


#
# Week marker stuff
#

my %weekmarkers;

my $weekmarkers_filename = "week_markers.txt";
if ( -e $weekmarkers_filename ) {

    open my $fh, "<", $weekmarkers_filename or die "Cannot open file '$weekmarkers_filename'.";

    while ( <$fh> ) {
        if ( /(\d+)\s+(.*)$/ ) {
            $weekmarkers{ $1 } = $2;
        }
    }

    close $fh;

}

#
# Day marker stuff
#

my %daymarkers;

my $daymarkers_filename = "day_markers.txt";
if ( -e $daymarkers_filename ) {

    open my $fh, "<", $daymarkers_filename or die "Cannot open file '$daymarkers_filename'.";

    while ( <$fh> ) {
        if ( /(\d{4}-\d\d-\d\d)\s+(.*)$/ ) {
            $daymarkers{ $1 } = $2;
        }
    }

    close $fh;

}



my $start_month_names_y = 25;
my $start_days_of_month_y = $start_month_names_y + 5;
my $month_w = 110;
my $day_step_h = 25;  # Day step height

for my $month ( 1 .. 12 ) {
    my $start_month_col_x = 10+$month_w*($month-1);

    printf "<text class='monthname' x='%d' y='%d'>%s</text>\n", $start_month_col_x, $start_month_names_y, $month_text[$month-1];

    my $days_this_month = 31;
    $days_this_month = 30 if $month==4 or $month==6 or $month==9 or $month==11;
    $days_this_month = 28 if $month==2; #TODO

    for my $day ( 1 .. $days_this_month ) {

        # Calculate positions
        my $day_y = $start_days_of_month_y + $day_step_h * $day;
        my $line_gap_w = 5;
        # Calculate day properties
        my $unix_ts = POSIX::mktime( 0, 0, 0,  $day, $month-1, $year-1900 );
        my $dayofweek = (localtime( $unix_ts ))[6];
        my $dayofyear = (localtime( $unix_ts ))[7];

        # Highlight day?
        my $ymd = sprintf "%04d-%02d-%02d", $year, $month, $day;
        if ( defined $highlight_days->[0]->{highlights}->{$ymd} ) {
            printf "<rect x='%d' y='%d' width='%d' height='%d' style='%s' />\n",
                    $start_month_col_x, $day_y - $day_step_h + 5 + 1,
                    $month_w-$line_gap_w, $day_step_h - 2,
                    $highlight_days->[0]->{highlights}->{$ymd};
        }

        # Check person's holidays
        for my $person ( sort keys %persons_holidays_table ) {
            die unless exists $persons_index{$person};
            if ( $persons_holidays_table{ $person }[$dayofyear] ) {
                # Calculate positions
                my $box_gap_w = 3;  # Gap to next box
                my $box_step_w = 10;  # Box step width
                my $box_w = $box_step_w - $box_gap_w;  # Width of box
                my $gap_to_left = $start_month_col_x + $persons_index{$person} * $box_step_w + 30;
                # Show box
                printf "<rect class='person_holiday_$person' x='%d' y='%d' width='%d' height='%d' />\n",
                        $gap_to_left, $day_y - $day_step_h + 5 + 1,
                        $box_w, $day_step_h - 2;

            }
        }

        # Day (1, 2, ...)
        printf "<text x='%d' y='%d'>%d</text>\n", $start_month_col_x, $day_y, $day;
        # Day of week
        printf "<text class='%s' x='%d' y='%d'>%s</text>\n",
               join( " ", grep length,
                     "nameofday",
                     "dayofweek$dayofweek",
                     defined $holidays->[0]->{holidays}->{$ymd} ? "holiday" : ""
                    ),
               $start_month_col_x + 25, $day_y,
               $dayofweek_text[$dayofweek];
        # Line below a cell
        printf "<line x1='%d' y1='%d' x2='%d' y2='%d' />\n", $start_month_col_x, $day_y+5, $start_month_col_x + $month_w - $line_gap_w, $day_y+5;

        # Get the week number (ISO 8601)
        my $timeobject = localtime( $unix_ts );
        my $weeknumber = $timeobject->week;

        # Show number of week on Mondays
        if ( $dayofweek == 1 ) {
            printf "<text class='weeknumber' x='%d' y='%d' text-anchor='end'>%d</text>\n", $start_month_col_x + $month_w - $line_gap_w, $day_y, $weeknumber;
        }

        # Show week markers on Wednesdays
        if ( $dayofweek == 3 ) {
            if ( exists $weekmarkers{ $weeknumber } ) {
                my $marker = $weekmarkers{ $weeknumber };
                printf "<text class='weekmarker' x='%d' y='%d' text-anchor='end'>%s</text>\n", $start_month_col_x + $month_w - $line_gap_w, $day_y, $marker;
            }
        }

        # Show day markers (if set)
        if ( exists $daymarkers{ $ymd } ) {
            my $marker = $daymarkers{ $ymd };
            printf "<text class='daymarker' x='%d' y='%d' text-anchor='end'>%s</text>\n", $start_month_col_x + $month_w - $line_gap_w * 2, $day_y, $marker;
        }

        # Notation?
        if ( defined $highlight_days->[0]->{notations}->{$ymd} ) {
            printf "<text class='notation' x='%d' y='%d'>%s</text>\n",
                    $start_month_col_x + int( $month_w / 2),
                    $day_y,
                    $highlight_days->[0]->{notations}->{$ymd};
        }
    }
}

print "</svg>\n";
