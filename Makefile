.PHONY: clean

SHELL: /bin/bash

clean:
	rm -f $(wildcard derived_data/*.csv)
	rm -f $(wildcard figures/*.png)

report.pdf:\
  report.Rmd\
  figures/figure01.png 
	Rscript -e "rmarkdown::render('report.Rmd',output_format='pdf_document')"

figures/figure01.png\
figures/figure03.png\
figures/figure04.png\
figures/figure05.png:\
 analysis.R\
 derived_data/Salary_US_major_group.csv\
 derived_data/Salary_State.csv\
 source_data/US_State/*
	Rscript analysis.R

derived_data/Salary_US.csv\
derived_data/Salary_State.csv\
derived_data/Salary_US_major_group.csv:\
 load_data.R\
 source_data/all_data_M_2020.csv
	Rscript load_data.R
