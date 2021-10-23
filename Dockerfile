FROM rocker/verse
WORKDIR /
RUN R -e "install.packages(\"tinytex\")"
RUN R -e "install.packages(\"reticulate\")"
