# Sbobina template

Here you find the [Rmarkdown template](template.Rmd) for the sbobina and the [pdf](template.pdf) rendered from it.

1. [Header](#header)
2. [Introduction](#introduction)
3. [Notes and Suggestions](#notes-and-suggestions)

## Header

Here there are the settings for the file, you need to modify
* Names
* Date

You can modify
* `toc_depth: 2` if you want more, or fewer, title levels displaied in the table of content/index

```
---
title: "Data Analysis (Prof. Ugo Ala) - R Practical N"
author: "Cognome Nome, Cognome Nome, Cognome Nome"
date: "01-01-0000"
output:
  pdf_document:
    latex_engine: xelatex
    keep_tex: true
    toc: true
    toc_depth: 2
header-includes:
  - \usepackage{fvextra}
  - \usepackage{fancyhdr}
  - \DefineVerbatimEnvironment{Highlighting}{Verbatim}{breaklines,breakanywhere=true,commandchars=\\\{\}}
  - \fvset{breaklines=true, breakanywhere=true}
  - \renewcommand{\contentsname}{Index}
  - \AtBeginDocument{
      \pagestyle{fancy}
      \fancyhead[L]{}
      \fancyhead[R]{}
      \fancyhead[C]{Data Analysis - R Practical N - 01-01-0000 - Cognome N., Cognome N., Cognome N.}
      \fancyfoot[C]{\thepage}
      \renewcommand{\sectionmark}[1]{}
      \renewcommand{\subsectionmark}[1]{}
    }
---

\thispagestyle{empty}

\newpage
\pagenumbering{arabic}
\setcounter{page}{1}
```

## Introduction

````markdown
# Introduction

## Environment

The exrcise was run in a Docker, at the moment only aversion with JupyterLab is available. The image can be pulled from GitHub:

```sh
docker pull ghcr.io/maiolino-au/data_analysis:latest
```

To run it open a terminal in the working directory and run this:

* In Windows

```powershell
@echo off
set "CURRENT_DIR=%cd%"
docker run -it --rm -p 8787:8787 -v "%CURRENT_DIR%:/sharedFolder" ghcr.io/maiolino-au/data_analysis:latest
\```

* In Linux / MacOS

```sh
docker run -it --rm -p 8787:8787 -v .:/sharedFolder ghcr.io/maiolino-au/data_analysis:latest
```

Repository link: https://github.com/Maiolino-Au/Data_Analysis

The datas used are availabe in the repository or on moodle.

The scripts assume that the working directory is the same where the data are stored.

\newpage
````

For the this section
* change `setwd("/sharedFolder/Practical_1/")` with the correct directory (remember that `Practical_1` is in the `sharedFolder`, so it is shared to the container from your computer)
* add packages if needed

````markdown
## Working directory and Packages

First of all, we need to set the correct working directory: all the commands assume that the datas are stored in the working directory. I worked in a docker container to which i have shared a directory from my PC, called `/sharedFolder` inside the docker. In the directory there is one specific for this lesson, called `Practical_1`. Therefore:

```{r, eval=T, echo=T}
setwd("/sharedFolder/Practical_1/")
```

Then we need to load the packages we are going to use. I used `suppressPackageStartupMessages()` to avoid printing all the startup messages of each package.

```{r, eval=T, echo=T}
suppressPackageStartupMessages({
    library(phyloseq)
    library(dplyr)
    library(tidyr)
    library(stringr)
    library(microbiome)
    library(microbial)
    library(vegan)
    library(usedist)
    library(ggplot2)
    library(nortest)
    library(car)
})
```

\newpage
````

# Notes and suggestions


there are up to 6 levels of titles (from # to ######), only level 1 and 2 will be shown in the table of content (Index), you can cahge it with toc_depth

# Render

`rmarkdown::render('/sharedFolder/Practical_1/Data_analysis_R_1.Rmd', output_dir = '/sharedFolder/Practical_1/')`

# Title
text text text

* lista
* lista

text text text

1. lista numerata
2. lista numerata
1. funziona anche se mettete un numero a caso (nel rendere vedete un 3)

bisogna mettere una rigavuota tra du cose 
per far sì che siano

separate

importante 
* per
* liste

triplette di backtick per un blocco di codice, singolo backtick per una riga di codice `mm <- c("m", "m")` che potete inerire nel testo. utile per dire "ho usato il comando `paste()` per unire due stringhe"

```{r, eval=T, echo=T}
mm <- c("m", "m")
paste(mm[1], mm[2], sep = " - ")
```

una variabile definita in un blocco si salva nel documento e può essere richiamata in blocchi successivi

```{r, eval=T, echo=T}
paste(mm[1], mm[2], sep = " - ")
```

## Warnings

