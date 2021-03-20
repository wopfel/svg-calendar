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
# Mark person's vacation in hash
#
# Parameter:
# 1: Person's name
# 2: Day of year
#

sub setVacation {

    my ( $name, $dayofyear ) = @_;

    $persons_holidays_table{$name}[$dayofyear] = 1;

}


#
# Get day of year from yyyy-mm-dd
#
# Parameters:
# 1: Year
# 2: The date (formatted as yyyy-mm-dd)
#

sub getDayOfYear {

    my ( $year, $ymd ) = @_;

    die "Wrong ymd format for '$ymd'" unless $ymd =~ /^(....)-(..)-(..)$/;

    my $y = $1;
    my $m = $2;
    my $d = $3;

    # Check if year is correct
    die "Wrong year passed in '$ymd'" if $y != $year;

    my $unix_ts = POSIX::mktime( 0, 0, 0, $d, $m-1, $y-1900 );
    my $dayofyear = (localtime( $unix_ts ))[7];

    return $dayofyear;

}


#
# Load vacation data from external file
#
# Parameter:
# 1: Year
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
            if ( $timerange =~ /^....-..-..$/ ) {
                my $dayofyear = getDayOfYear( $year, $timerange );
                setVacation( $name, $dayofyear );
                next;
            }

            # Range (from/to), inluding year
            if ( $timerange =~ /^(....-..-..) - (....-..-..)$/ ) {
                my $from = $1;
                my $to = $2;
                my $dayofyear_begin = getDayOfYear( $year, $from );
                my $dayofyear_end = getDayOfYear( $year, $to );
                die if $dayofyear_end < $dayofyear_begin;
                # For each day, mark person's table
                for ( $dayofyear_begin .. $dayofyear_end ) {
                    setVacation( $name, $_ );
                }
                next;
            }

            # Single day (format mm-dd, current year)
            if ( $timerange =~ /^(..)-(..)$/ ) {
                my $dayofyear = getDayOfYear( $year, "$year-$timerange" );
                setVacation( $name, $dayofyear );
                next;
            }

            # Range (from/to), omitting year
            if ( $timerange =~ /^(..-..) - (..-..)$/ ) {
                my $from = $1;
                my $to = $2;
                my $dayofyear_begin = getDayOfYear( $year, "$year-$from" );
                my $dayofyear_end = getDayOfYear( $year, "$year-$to" );
                die if $dayofyear_end < $dayofyear_begin;
                # For each day, mark person's table
                for ( $dayofyear_begin .. $dayofyear_end ) {
                    setVacation( $name, $_ );
                }
                next;
            }

            # Range (from/to), inluding year in from data, omitting year in to data
            if ( $timerange =~ /^(....-..-..) - (..-..)$/ ) {
                my $from = $1;
                my $to = $2;
                my $dayofyear_begin = getDayOfYear( $year, $from );
                my $dayofyear_end = getDayOfYear( $year, "$year-$to" );
                die if $dayofyear_end < $dayofyear_begin;
                # For each day, mark person's table
                for ( $dayofyear_begin .. $dayofyear_end ) {
                    setVacation( $name, $_ );
                }
                next;
            }

            # Bail out if line cannot be parsed
            die "Couldn't parse timerange '$timerange'";

        }
    }

}

1;
