FROM ghcr.io/maiolino-au/monocle:v1.0.1

RUN R -e "devtools::install_github('jbisanz/qiime2R')"
RUN R -e "install.packages(c('microbiome', 'microbial', 'usedist', 'nortest', 'car'))"
RUN R -e "devtools::install_github('microbiome/microbiome')"



ENV SHELL=/bin/bash
CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8787", "--no-browser", "--allow-root", "--ServerApp.allow_origin='*'", "--ServerApp.token=''"]
