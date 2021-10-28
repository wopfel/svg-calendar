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
use Getopt::Long;

# Local libraries
use lib "./libs/.";
use vacation;


#
# Process command line arguments
#

# Year from command line (default: current year)
my $year = 1900 + (localtime)[5];
# Weekmarker filename (sample: week_markers.txt)
my $weekmarkers_filename;
# Daymarker filename (sample: day_markers.txt)
my $daymarkers_filename;

GetOptions( "year=i"       => \$year,
            "weekmarker=s" => \$weekmarkers_filename,
            "daymarker=s"  => \$daymarkers_filename,
          )
or die "Error in command line argument processing";


# Calendar size data
my $start_month_names_y = 25;
my $start_days_of_month_y = 5;
my $month_w = 110;
my $day_step_h = 25;  # Day step height
my $margin_left = 10;
my $line_gap_below = 5;  # Distance of the line below each day cell


#
# Sub: check if the given year is a leap year
#
# Parameter:
# 1: year
#

sub isLeapYear {

    my $year = shift;

    return 0 if $year % 4;
    return 1 if $year % 100;
    return 0 if $year % 400;
    return 1;

}


#
# Print svg header infos
#

print qq{<?xml version="1.0" encoding="UTF-8" standalone="no"?>\n};
print qq{<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">\n};

print qq{<?xml-stylesheet type="text/css" href="svg-calendar.css" ?>\n};

# Calculate width and height
my $svg_width = $month_w * 12 + $margin_left;
my $svg_height = $start_month_names_y + $start_days_of_month_y + 31 * $day_step_h + $line_gap_below + 2;

printf qq{<svg height="%d" width="%d" xmlns="%s" xmlns:xlink="%s" xml:space="preserve">\n},
    $svg_height, $svg_width,
    "http://www.w3.org/2000/svg",
    "http://www.w3.org/1999/xlink";


# Month names, and day-of-week names (DE)
my @month_text = qw/ Jan Feb Mär Apr Mai Jun Jul Aug Sep Okt Nov Dez /;
my @dayofweek_text = qw/ So Mo Di Mi Do Fr Sa /;


#
# Read highlight days (also used for notations)
#

my $highlight_days = YAML::Tiny->read( "highlight_days.yml" );
die "Error in yml file 'highlight_days.yml'"  unless  $highlight_days;


#
# Read holidays
#

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

if ( $weekmarkers_filename and -e $weekmarkers_filename ) {

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

if ( $daymarkers_filename and -e $daymarkers_filename ) {

    open my $fh, "<", $daymarkers_filename or die "Cannot open file '$daymarkers_filename'.";

    while ( <$fh> ) {
        if ( /(\d{4}-\d\d-\d\d)\s+(.*)$/ ) {
            $daymarkers{ $1 } = $2;
        }
    }

    close $fh;

}


#
# Create calendar by printing svg elements
#

# Cycle through all months (January -> December)
for my $month ( 1 .. 12 ) {
    my $start_month_col_x = $margin_left + $month_w*($month-1);

    # Begin group (month)
    printf "<g transform='translate(%d,%d)'>\n",
           $start_month_col_x,
           $start_month_names_y;

    printf "<text class='monthname' x='%d' y='%d'>%s</text>\n",
        0, 0, $month_text[$month-1];

    my $days_this_month = 31;
    $days_this_month = 30 if $month==4 or $month==6 or $month==9 or $month==11;
    $days_this_month = isLeapYear($year) ? 29 : 28 if $month==2;

    # Cycle through all days (1 -> 28/29/30/31)
    for my $day ( 1 .. $days_this_month ) {

        # Calculate positions
        my $day_y = $start_days_of_month_y + $day_step_h * $day;
        my $line_gap_w = 5;
        # Calculate day properties
        my $unix_ts = POSIX::mktime( 0, 0, 0,  $day, $month-1, $year-1900 );
        my $dayofweek = (localtime( $unix_ts ))[6];
        my $dayofyear = (localtime( $unix_ts ))[7];

        # Begin group (day)
        printf "<g transform='translate(%d,%d)'>\n",
               0,
               $day_y;

        # Highlight day?
        my $ymd = sprintf "%04d-%02d-%02d", $year, $month, $day;
        if ( defined $highlight_days->[0]->{highlights}->{$ymd} ) {
            printf "<rect x='%d' y='%d' width='%d' height='%d' style='%s' />\n",
                    0, 0 - $day_step_h + 5 + 1,
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
                my $gap_to_left = 30 + $persons_index{$person} * $box_step_w;
                # Show box
                printf "<rect class='%s' x='%d' y='%d' width='%d' height='%d' />\n",
                        "person_holiday_$person",
                        $gap_to_left, 0 - $day_step_h + 5 + 1,
                        $box_w, $day_step_h - 2;
            }
        }

        # Day (1, 2, ...)
        printf "<text class='%s' x='%d' y='%d'>%d</text>\n",
               "dayofmonth", 0, 0, $day;
        # Day of week
        printf "<text class='%s' x='%d' y='%d'>%s</text>\n",
               join( " ", grep length,
                     "nameofday",
                     "dayofweek$dayofweek",
                     defined $holidays->[0]->{holidays}->{$ymd} ? "holiday" : ""
                    ),
               25, 0,
               $dayofweek_text[$dayofweek];
        # Line below a cell
        printf "<line x1='%d' y1='%d' x2='%d' y2='%d' />\n",
                0, $line_gap_below,
                $month_w - $line_gap_w, $line_gap_below;

        # Get the week number (ISO 8601)
        my $timeobject = localtime( $unix_ts );
        my $weeknumber = $timeobject->week;

        # Show number of week on Mondays
        if ( $dayofweek == 1 ) {
            printf "<text class='weeknumber' x='%d' y='%d' text-anchor='end'>%d</text>\n",
                    $month_w - $line_gap_w, 0, $weeknumber;
        }

        # Show week markers on Wednesdays
        if ( $dayofweek == 3 ) {
            if ( exists $weekmarkers{ $weeknumber } ) {
                my $marker = $weekmarkers{ $weeknumber };
                printf "<text class='weekmarker' x='%d' y='%d' text-anchor='end'>%s</text>\n",
                        $month_w - $line_gap_w, 0, $marker;
            }
        }

        # Show day markers (if set)
        if ( exists $daymarkers{ $ymd } ) {
            my $marker = $daymarkers{ $ymd };
            printf "<text class='daymarker' x='%d' y='%d' text-anchor='end'>%s</text>\n",
                    $month_w - $line_gap_w * 2, 0, $marker;
        }

        # Notation?
        if ( defined $highlight_days->[0]->{notations}->{$ymd} ) {
            printf "<text class='notation' x='%d' y='%d'>%s</text>\n",
                    int( $month_w / 2),
                    0,
                    $highlight_days->[0]->{notations}->{$ymd};
        }

        # End group (day)
        printf "</g>\n";

    }

    # End group (month)
    printf "</g>\n";
}

print "</svg>\n";
