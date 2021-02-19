# svg-calendar
Creating a calendar (.svg file)

Create .svg file by running

`perl svg-calendar.pl > test-calendar.svg`

Open file in a browser.

See sample output in file `sample-calendar.svg`.

For development:

Run `while true ; do make ; sleep 1 ; done`


Requirements
============

The following perl libraries have to be installed:

- POSIX
- Time::Piece
- YAML::Tiny
