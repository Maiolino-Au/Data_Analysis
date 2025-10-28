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

# -----------------------------
# Install RStudio Server
# -----------------------------
ENV RSTUDIO_VERSION=2024.09.0+375

RUN wget https://download2.rstudio.org/server/jammy/amd64/rstudio-server-${RSTUDIO_VERSION}-amd64.deb && \
    gdebi -n rstudio-server-${RSTUDIO_VERSION}-amd64.deb && \
    rm rstudio-server-${RSTUDIO_VERSION}-amd64.deb

# Create rstudio user (no password, no auth)
RUN useradd -m rstudio && \
    adduser rstudio sudo && \
    mkdir -p /var/run/rstudio-server && \
    chown -R rstudio:rstudio /var/run/rstudio-server

# -----------------------------
# Scripts to launch either Jupyter or RStudio
# -----------------------------
# Default: JupyterLab on port 8787 (no token, no browser)
COPY <<'EOF' /usr/local/bin/start-jupyter
#!/bin/bash
exec jupyter lab --ip=0.0.0.0 --port=8787 --no-browser --allow-root \
  --ServerApp.allow_origin='*' --ServerApp.token='' --ServerApp.password=''
EOF
RUN chmod +x /usr/local/bin/start-jupyter

# Optional: start RStudio (no auth)
COPY <<'EOF' /usr/local/bin/start-rstudio
#!/bin/bash
echo "Launching RStudio Server (no authentication)..."
exec /usr/lib/rstudio-server/bin/rserver \
  --server-daemonize=0 \
  --auth-none=1 \
  --www-port=8787 \
  --server-user=rstudio
EOF
RUN chmod +x /usr/local/bin/start-rstudio

# -----------------------------
# Default command: JupyterLab
# -----------------------------
EXPOSE 8787
ENV SHELL=/bin/bash
CMD ["start-jupyter"]

# ENV SHELL=/bin/bash
# CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8787", "--no-browser", "--allow-root", "--ServerApp.allow_origin='*'", "--ServerApp.token=''"]
