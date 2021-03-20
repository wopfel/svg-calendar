data_files = day_markers.txt highlight_days.yml vacation.yml holidays.yml \
             week_markers.txt

sample-calendar.svg: svg-calendar.pl $(data_files)
	perl svg-calendar.pl > sample-calendar.svg
