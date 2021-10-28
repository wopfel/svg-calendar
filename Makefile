data_files = day_markers.txt highlight_days.yml vacation.yml holidays.yml \
             week_markers.txt Makefile

perl_modules = libs/vacation.pm

parameters += -year 2021
parameters += -weekmarker week_markers.txt
parameters += -daymarker day_markers.txt
parameters += -highlightdays highlight_days.yml
parameters += -vacation vacation.yml

sample-calendar.svg: svg-calendar.pl $(data_files) $(perl_modules)
	perl svg-calendar.pl $(parameters) > sample-calendar.svg
