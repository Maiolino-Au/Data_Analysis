# Data_Analysis

To download the docker:

* with JupyterLab

```sh
docker pull ghcr.io/maiolino-au/data_analysis:v0.1.0
```


* with Rstudio

```sh
###
```

Remember: uses port 8787

Run the docker you downloaded (regardless of the version):
* on Windows

```cmd
@echo off
set "CURRENT_DIR=%cd%"
docker run -it --rm -p 8787:8787 -v "%CURRENT_DIR%:/sharedFolder" ghcr.io/maiolino-au/data_analysis
```

* on Linux/Mac

```sh
docker run -it --rm -p 8787:8787 -v .:/sharedFolder ghcr.io/maiolino-au/data_analysis
```
