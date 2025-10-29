# Data_Analysis

To download the docker:

```sh
docker pull ghcr.io/maiolino-au/data_analysis:latest
```

Remember: uses port 8787

Run the docker you downloaded:
* on Windows ([script](data_analysis.cmd))

```cmd
@echo off
set "CURRENT_DIR=%cd%"
docker run -it --rm -p 8787:8787 -v "%CURRENT_DIR%:/sharedFolder" ghcr.io/maiolino-au/data_analysis:latest
```

* on Linux/Mac ([script](data_analysis.sh))

```sh
docker run -it --rm -p 8787:8787 -v .:/sharedFolder ghcr.io/maiolino-au/data_analysis:latest
```
