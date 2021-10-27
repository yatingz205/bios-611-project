.PHONY: clean
SHELL: /bin/bash

clean:
        rm -f derived_data/$(wildcard *.csv)

derived_data/Salary_US_major_group.csv: source_data/all_data_M_2020.csv
	Rscript load_data.R

