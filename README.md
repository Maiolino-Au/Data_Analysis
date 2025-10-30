# Data_Analysis

Practical lesson held by professor [Ugo Ala](https://www.molecularbiotechnology.unito.it/do/docenti.pl/Show?_id=uala#tab-profilo) for the module "Advanced data analysis for biological processes" of the course "Advanced Chemical and Bioinformatics Aapproaches for Health Sciences ", Master's Degree in [Molecular Biotechnology](https://www.molecularbiotechnology.unito.it/do/home.pl) at the [University of Turin](https://www.unito.it/).

Practical 1 (22/10/2025) curated by:
* Fontanilla Natasha
* Maiolino Aurelio
* Mercadante Marianna

Practical 2 (29/10/2025) curated by:
* Lo Bianco Francesca
* Malta Alessandra
* Scelza Giorgia


# Docker environment 

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

