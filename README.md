# svg-calendar

Creates an image of an annual calendar (kind of a wall calendar).
The calendar is saved as a .svg file.


How to create the calendar file
===============================

Review the following files

- week_markers.txt: place markers (example: place a "C" on 3rd week of this year)
- day_markers.txt: place markers on single days
- highlight_days.yml: format specific days using CSS (example: background color of Dec 24th)
- holiday_data.txt: person's holidays
- svg-calendar.css: CSS definitions for the SVG file

Create the .svg file by running

`perl svg-calendar.pl > test-calendar.svg`

Open file `test-calendar.svg` in a browser.


Sample
======

See sample output in file `sample-calendar.svg`.


File holiday_data.txt
=====================

The index value influences the vertical bar. The higher the index value is, the
more the bar moves to the right. I think an index value greater 5 isn't suitable
at the moment, otherwise the vertical bar overlaps the next month.

![Holiday data](documentation/holiday_data.png)


Developer hints
===============

Run `while true ; do make ; sleep 1 ; done`


Requirements
============

The following perl libraries have to be installed:

- POSIX
- Time::Piece
- YAML::Tiny
