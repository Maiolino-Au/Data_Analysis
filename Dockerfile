FROM satijalab/seurat

RUN apt-get update && apt-get -y install gdebi-core wget
RUN apt-get update && apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
RUN apt-get update && apt install -y libudunits2-dev libgdal-dev
RUN apt-get update && apt-get -y install gfortran build-essential fort77 xorg-dev liblzma-dev libblas-dev gfortran gobjc++ aptitude libbz2-dev libpcre3-dev
RUN aptitude -y install libreadline-dev
RUN apt-get -y install libcurl4-openssl-dev
RUN apt install -y build-essential libcurl4-gnutls-dev libxml2-dev libssl-dev
RUN apt-get update && apt-get install -y --no-install-recommends \
    software-properties-common dirmngr gpg curl build-essential \
    libcurl4-openssl-dev build-essential libcurl4-openssl-dev libssl-dev \
    libgit2-dev libharfbuzz-dev libfribidi-dev cmake libcairo2-dev \
    libcurl4-openssl-dev libssl-dev libxml2-dev libfontconfig1-dev \
    libfreetype6-dev libpng-dev libtiff5-dev libjpeg-dev libharfbuzz-dev \
    libfribidi-dev make cmake gfortran libxt-dev liblapack-dev libblas-dev \
    sudo wget zlib1g-dev libbz2-dev liblzma-dev libncurses5-dev pandoc git nano && \
    rm -rf /var/lib/apt/lists/*

# Install JupyterLab
RUN sudo apt update && sudo apt install -y python3 python3-pip python3-venv
# create a virtual environment in which JupyterLab can be installed
RUN python3 -m venv /opt/venv
# Activate virtual environment and install JupyterLab
RUN /opt/venv/bin/pip install --upgrade pip && /opt/venv/bin/pip install jupyterlab
# Set the virtual environment as the default Python path
ENV PATH="/opt/venv/bin:$PATH"
# Make R visible to jupyter
RUN R -e "install.packages('IRkernel')" && \
    R -e "IRkernel::installspec(user = FALSE)"


RUN R -e "install.packages(c('systemfonts', 'textshaping', 'ragg', 'pkgdown', 'devtools', 'dplyr', 'ggplot2', 'data.table', 'future', 'cowplot', 'remotes', 'R.utils', 'dplyr', 'rtracklayer', 'tinytex'))" 
RUN R -e "devtools::install_github('jbisanz/qiime2R')"
RUN R -e "install.packages(c('microbiome', 'microbial', 'usedist', 'nortest', 'car'))"
RUN R -e "devtools::install_github('microbiome/microbiome')"
RUN R -e "tinytex::install_tinytex()"



ENV SHELL=/bin/bash
CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8787", "--no-browser", "--allow-root", "--ServerApp.allow_origin='*'", "--ServerApp.token=''"]
