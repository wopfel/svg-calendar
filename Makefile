data_files = day_markers.txt highlight_days.yml vacation.yml holidays.yml \
             week_markers.txt Makefile

perl_modules = libs/vacation.pm

sample-calendar.svg: svg-calendar.pl $(data_files) $(perl_modules)
	perl svg-calendar.pl -year 2021 -weekmarker week_markers.txt -daymarker day_markers.txt > sample-calendar.svg
