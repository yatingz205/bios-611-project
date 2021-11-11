# bios-611-project

## Overview:
This project investigates employment and salary data in the United States by industry and occupation, where
Industry is cagegorized by the **North American Industry Classification System (NAICS)**
and occupation by the **Standard Occupational Classification (SOC) System**.

## Instruction:
 - Build the image for this project by typing: 
```
docker build . -t pj
```
 - Then start RStudio by typing:
```
docker run -e PASSWORD=some_password --rm -v $(pwd):/home/rstudio/ -p 8787:8787 -t pj
```
 - Once the Rstudio is running connect to it by visiting
https://localhost:8787 in your browser. Log in with username `rstudio` and the password you entered after `PASSWORD=`.

 - Type `shiny::runApp('/home/rstudio/shiny_treemap.R')` in RStudio to start the shiny interactive app. Then the interactive plot will be shown in a pop-up.
 
 - Type `make report.pdf` in the terminal inside Rstudio to create the final report.

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
