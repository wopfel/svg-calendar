package vacation;

use strict;
use warnings;
use parent 'Exporter';


# A hash of arrays:
# $persons_holidays_table{<person name from [name] used in holiday_data.txt>}[<day of year>]: set to 1 if person is on holiday on this day
our %persons_holidays_table;

# Used for holidays' highlighting to place markers side by side
our %persons_index;

our @EXPORT = qw( %persons_holidays_table %persons_index );


#
# Load vacation data from external file
#

sub load {

    my $year = shift;

    # Person's vacation
    my $vacation = YAML::Tiny->read( "vacation.yml" );
    die "Error in yml file 'vacation.yml'"  unless  $vacation;

    # Calculate a table for each person, setting dayofyear to 1 if person is in vacation
    for my $block ( @{ $vacation->[0]->{vacation} } ) {
        my $name = $block->{name};
        my $index = $block->{index};

        $persons_index{ $name } = $index;

        for my $timerange ( @{ $block->{times} } ) {

            # Single day (format yyyy-mm-dd)
            if ( $timerange =~ /^(....)-(..)-(..)$/ ) {
                my $y = $1;
                my $m = $2;
                my $d = $3;
                # Check if year is correct
                die "Wrong year" if $y != $year;
                # Calculate date of holiday
                my $unix_ts = POSIX::mktime( 0, 0, 0, $d, $m-1, $y-1900 );
                my $dayofyear = (localtime( $unix_ts ))[7];
                $persons_holidays_table{$name}[$dayofyear] = 1;
                next;
            }

            # Range (from/to), inluding year
            if ( $timerange =~ /^(....-..-..) - (....-..-..)$/ ) {
                my $from = $1;
                my $to = $2;
                my ( $y, $m, $d );
                # Calculate beginning of holidays
                ( $y, $m, $d ) = $from =~ /^(....)-(..)-(..)$/;
                # Check if year is correct
                die "Wrong year" if $y != $year;
                my $unix_ts;
                $unix_ts = POSIX::mktime( 0, 0, 0, $d, $m-1, $y-1900 );
                my $dayofyear_begin = (localtime( $unix_ts ))[7];
                # Calculate ending of holidays
                ( $y, $m, $d ) = $to =~ /^(....)-(..)-(..)$/;
                # Check if year is correct
                die "Wrong year" if $y != $year;
                $unix_ts = POSIX::mktime( 0, 0, 0, $d, $m-1, $y-1900 );
                my $dayofyear_end = (localtime( $unix_ts ))[7];
                die if $dayofyear_end < $dayofyear_begin;
                # For each day, set table to 1 for later lookup
                for ( $dayofyear_begin .. $dayofyear_end ) {
                    $persons_holidays_table{$name}[$_] = 1;
                }
                next;
            }

            # Single day (format mm-dd, current year)
            if ( $timerange =~ /^(..)-(..)$/ ) {
                my $y = $year;
                my $m = $1;
                my $d = $2;
                # Check if year is correct
                die "Wrong year" if $y != $year;
                # Calculate date of holiday
                my $unix_ts = POSIX::mktime( 0, 0, 0, $d, $m-1, $y-1900 );
                my $dayofyear = (localtime( $unix_ts ))[7];
                $persons_holidays_table{$name}[$dayofyear] = 1;
                next;
            }

            # Range (from/to), omitting year
            if ( $timerange =~ /^(..-..) - (..-..)$/ ) {
                my $from = $1;
                my $to = $2;
                my ( $y, $m, $d );
                $y = $year;
                # Calculate beginning of holidays
                ( $m, $d ) = $from =~ /^(..)-(..)$/;
                # Check if year is correct (doesn't harm if checked here too)
                die "Wrong year" if $y != $year;
                my $unix_ts;
                $unix_ts = POSIX::mktime( 0, 0, 0, $d, $m-1, $y-1900 );
                my $dayofyear_begin = (localtime( $unix_ts ))[7];
                # Calculate ending of holidays
                ( $m, $d ) = $to =~ /^(..)-(..)$/;
                # Check if year is correct (doesn't harm if checked here too)
                die "Wrong year" if $y != $year;
                $unix_ts = POSIX::mktime( 0, 0, 0, $d, $m-1, $y-1900 );
                my $dayofyear_end = (localtime( $unix_ts ))[7];
                die if $dayofyear_end < $dayofyear_begin;
                # For each day, set table to 1 for later lookup
                for ( $dayofyear_begin .. $dayofyear_end ) {
                    $persons_holidays_table{$name}[$_] = 1;
                }
                next;
            }

            # Range (from/to), inluding year in from data, omitting year in to data
            if ( $timerange =~ /^(....-..-..) - (..-..)$/ ) {
                my $from = $1;
                my $to = $2;
                my ( $y, $m, $d );
                # Calculate beginning of holidays
                ( $y, $m, $d ) = $from =~ /^(....)-(..)-(..)$/;
                # Check if year is correct
                die "Wrong year" if $y != $year;
                my $unix_ts;
                $unix_ts = POSIX::mktime( 0, 0, 0, $d, $m-1, $y-1900 );
                my $dayofyear_begin = (localtime( $unix_ts ))[7];
                # Calculate ending of holidays
                ( $m, $d ) = $to =~ /^(..)-(..)$/;
                $y = $year;
                # Check if year is correct
                die "Wrong year" if $y != $year;
                $unix_ts = POSIX::mktime( 0, 0, 0, $d, $m-1, $y-1900 );
                my $dayofyear_end = (localtime( $unix_ts ))[7];
                die if $dayofyear_end < $dayofyear_begin;
                # For each day, set table to 1 for later lookup
                for ( $dayofyear_begin .. $dayofyear_end ) {
                    $persons_holidays_table{$name}[$_] = 1;
                }
                next;
            }

            # Bail out if line cannot be parsed
            die "Couldn't parse timerange '$timerange'";

        }
    }

}

1;
