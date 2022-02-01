Characterization of Inflammatory Bowel Disease Patient Cohorts
=============

<img src="https://img.shields.io/badge/Study%20Status-Repo%20Created-lightgray.svg" alt="Study Status: Repo Created">

- Analytics use case(s): **Characterization**
- Study type: **Clinical Application**
- Tags: **OHDSI, IBD, Crohn's disease, Ulcerative colitis**
- Study lead: **Chen Yanover**
- Study lead forums tag: **[cyanover](https://forums.ohdsi.org/u/cyanover)**
- Study start date: **-**
- Study end date: **-**
- Protocol: **[Word Doc](https://github.com/ohdsi-studies/IbdCharacterization/blob/master/documents/Protocol%20IBD%20Characterisation%20V1.6.docx)**
- Publications: **-**
- Results explorer: **-**

In this study we will describe the baseline demographic and clinical characteristics, as well as the occurrence of treatments and outcomes of individuals diagnosed with inflammatory bowel disease (IBD) and, specifically, with Crohn’s disease and ulcerative colitis. The analysis package is a near-duplicate of the [CHARYBDIS characterization code](https://github.com/ohdsi-studies/Covid19CharacterizationCharybdis) for SARS-CoV-2 and COVID-19, replacing cohort, staratum, and feature defintions with IBD ones.  

## Package Requirements
- A database in [Common Data Model version 5](https://github.com/OHDSI/CommonDataModel) in one of these platforms: SQL Server, Oracle, PostgreSQL, IBM Netezza, Apache Impala, Amazon RedShift, or Microsoft APS.
- R version 3.5.0 or newer
- On Windows: [RTools](http://cran.r-project.org/bin/windows/Rtools/)
- [Java](http://java.com)
- Suggested: 25 GB of free disk space

## Installation
You cam install the IBD characterization package using the following methiods:
1) Github: 
````
install.packages("devtools")
devtools::install_github("ohdsi-studies/IbdCharacterization")
````
Note: this method directly installs the package in your 
2) Zip file:

Download the repository [Zip file](https://github.com/ohdsi-studies/IbdCharacterization/archive/master.zip), copy it into your `R`or`RStudio` environment, and unzip it. Doouble 

An example of how to call ZIP files into your `R` environment can be found in the [The Book of OHDSI](https://ohdsi.github.io/TheBookOfOhdsi/PopulationLevelEstimation.html#running-the-study-package).*





3) renv: 

## Running the Study