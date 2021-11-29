# bios-611-project

## Overview:
This project investigates employment and salary data in the United States in 2020, where Industry is cagegorized by the **North American Industry Classification System (NAICS)** and occupation by the **Standard Occupational Classification (SOC) System**. 
There are four sections of analysis centered around our parameter of interest. In the first section, we categorize our data by industry according to the North American Industry Classification System (NAICS) and analyze the distribution of hourly wage within each industry. In the second section, we categorize our data based on the six-digit 2018 Standard Occupational Classification (SOC) code. In the third section, we group the data by state and focus on the spatial pattern of total employment and income level across states. In the fourth section, we combine employment data with estimated automation probability score (Frey & Osborne, 2017) and investigate the relationship between salary, employment, and the predicted chance of automation across occupations.

## Instruction:
#### Build Environment
 - Build the image for this project by typing: 
```
docker build . -t pj
```
 - Then start RStudio in your web browser by typing:
```
docker run -e PASSWORD=<some_password> --rm -v $(pwd):/home/rstudio/ -p 8787:8787 -t pj
```
 - Once the Rstudio is running connect to it by visiting
https://localhost:8787 in your browser. Log in with username `rstudio` and the password you entered after `PASSWORD=`.

#### Shiny App
 - There are two shiny interactive apps for this project. `shiny_treemap.R` visualizes total employment and mean hourly wage within a selected sector, while `shiny_barplot.R` visualizes the two across states within a selected occupation. To start either one, type:
`shiny::runApp('/home/rstudio/<name of the shiny script>')` in RStudio's terminal to start the shiny app. Then the interactive plot will be shown in a pop-up.
 
#### Generate Results
 - Type `make report.pdf` in the terminal to create the final report.
 - Each R script generates the figures for a particular section. If interested in the analysis in a particular section, run load_data.R first, and then the R script for that section.

## Appendix:
**Dataset link and reference:**

1. Salary Data:
https://www.bls.gov/oes/special.requests/oesm20all.zip  
from: U.S. BUREAU OF LABOR STATISTICS

2. Automation Probability Data:
https://www.kaggle.com/andrewmvd/occupation-salary-and-likelihood-of-automation  
from: The future of employment: How susceptible are jobs to computerisation?  
DOI: 10.1016/j.techfore.2016.08.019  
Journal: Technological Forecasting and Social Change  
Volume: 114  
Author: Frey, Carl Benedikt and Osborne, Michael A.  
Year: 2017  
Pages: 254–280  

3. North American Industry Classification System (NAICS)  
https://www.census.gov/naics/

4. Standard Occupational Classification (SOC) System  
https://www.bls.gov/soc/
