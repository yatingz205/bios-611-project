FROM rocker/verse
WORKDIR /project
RUN -e "install.packages(\"xlsx\")"
RUN R -e "install.packages(\"tinytex\")"
RUN R -e "install.packages(\"reticulate\")"
