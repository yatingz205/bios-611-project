FROM rocker/verse
MAINTAINER Yating Zou <yating@ad.unc.edu>

WORKDIR /
RUN R -e "install.packages(c('readr','stringr'))"
RUN R -e "install.packages(c('tidyr','dplyr','ggplot2'))"
RUN R -e "install.packages(c('treemapify','forcats'))"
RUN R -e "install.packages('shiny')"
RUN R -e "install.packages('tinytex'); tinytex::install_tinytex(dir='/opt/tinytex')"
