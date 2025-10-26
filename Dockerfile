FROM ghcr.io/maiolino-au/monocle:v1.0.1

RUN apt-get update && apt-get install -y --no-install-recommends \
    software-properties-common dirmngr gpg curl build-essential \
    libcurl4-openssl-dev libssl-dev libxml2-dev libfontconfig1-dev libfreetype6-dev \
    libpng-dev libtiff5-dev libjpeg-dev libharfbuzz-dev libfribidi-dev \
    make cmake gfortran libxt-dev liblapack-dev libblas-dev sudo wget \
    zlib1g-dev libbz2-dev liblzma-dev libncurses5-dev pandoc git

RUN R -e "devtools::install_github('jbisanz/qiime2R')"
RUN R -e "install.packages(c('microbiome', 'microbial', 'usedist', 'nortest', 'car', 'R.utils', 'dplyr', 'rtracklayer', 'tinytex'))"
RUN R -e "devtools::install_github('microbiome/microbiome')"
RUN R -e "tinytex::install_tinytex()"



ENV SHELL=/bin/bash
CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8787", "--no-browser", "--allow-root", "--ServerApp.allow_origin='*'", "--ServerApp.token=''"]
