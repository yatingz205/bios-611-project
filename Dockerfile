FROM rocker/verse
WORKDIR /
RUN R -e "install.packages(\"readr\")"
RUN R -e "install.packages(\"tidyr\")"
RUN R -e "install.packages(\"dplyr\")"
RUN R -e "install.packages(\"stringr\")"
RUN R -e "install.packages(\"forcats\")"
RUN R -e "install.packages(\"treemapify\")"
RUN R -e "install.packages(\"ggplot2\")"
RUN R -e "install.packages(\"shiny\")"
