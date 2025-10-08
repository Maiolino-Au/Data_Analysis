# Data_Analysis


Remember: uses port 8787


Run the docker on windows

```cmd
@echo off
set "CURRENT_DIR=%cd%"
docker run -it --rm -p 8787:8787 -v "%CURRENT_DIR%:/sharedFolder" ghcr.io/maiolino-au/data_analysis:latest
```

Run on linux

```sh
docker run -it --rm -p 8787:8787 -v .:/sharedFolder ghcr.io/maiolino-au/data_analysis:latest
```
