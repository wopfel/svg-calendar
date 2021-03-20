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


File vacation.yml
=================

The index value influences the vertical bar. The higher the index value is, the
more the bar moves to the right. I think an index value greater 5 isn't suitable
at the moment, otherwise the vertical bar overlaps the next month.

The color of the vertical bar can be changed in the CSS file. By default, the
bar is black. Having an element `name: bs` in the YML file, you can change the
styling by setting `.person_holiday_bs` in the CSS file.

![Vacation](documentation/vacation.png)

Vacation can be specified using the following formats:

- `yyyy-mm-dd - yyyy-mm-dd`: from (first day), to (last day)
- `yyyy-mm-dd - mm-dd`: same as before, omitting the year in 2nd part
- `yyyy-mm-dd`: only on this day
- `mm-dd - mm-dd`: from (first day), to (last day) omitting the year
- `mm-dd`: only on this day, omitting the year


File highlight_days.yml
=======================

You can format a day's cell using css code, or you can add notations.

![Highlight days](documentation/highlight_days.png)


File holidays.yml
=================

Defining (public) holidays. The weekday text is formatted using CSS
`text.holiday`.

![Holidays](documentation/holidays.png)


Developer hints
===============

Run `while true ; do make ; sleep 1 ; done`


Requirements
============

The following perl libraries have to be installed:

- POSIX
- Time::Piece
- YAML::Tiny
