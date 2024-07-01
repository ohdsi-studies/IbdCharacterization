Characterization of Inflammatory Bowel Disease Patient Cohorts
=============

<img src="https://img.shields.io/badge/Study%20Status-Results%20Available-brightgreen.svg" alt="Study Status: Results Available">


- Analytics use case(s): **Characterization**
- Study type: **Clinical Application**
- Tags: **OHDSI, IBD, Crohn's disease, Ulcerative colitis**
- Study lead: **Chen Yanover**
- Study lead forums tag: **[cyanover](https://forums.ohdsi.org/u/cyanover)**
- Study start date: **Mar 1, 2022**
- Study end date: **Sep 1, 2022**
- Protocol: **[Word Doc](https://github.com/ohdsi-studies/IbdCharacterization/blob/master/documents/Protocol%20IBD%20Characterisation%20V1.7.docx)**
- Publications: **-**
- Results explorer: **[Shiny app](https://data.ohdsi.org/IbdCharacterization/)**

In this study we will describe the baseline demographic and clinical characteristics, as well as the occurrence of treatments and outcomes of individuals diagnosed with inflammatory bowel disease (IBD) and, specifically, with Crohn’s disease and ulcerative colitis. The analysis package is a near-duplicate of the [CHARYBDIS characterization code](https://github.com/ohdsi-studies/Covid19CharacterizationCharybdis) for SARS-CoV-2 and COVID-19, replacing cohort, stratum, and feature definitions with IBD ones.  

## Package Requirements
- A database in [Common Data Model version 5](https://github.com/OHDSI/CommonDataModel) in one of these platforms: SQL Server, Oracle, PostgreSQL, IBM Netezza, Apache Impala, Amazon RedShift, or Microsoft APS.
- R version 3.5.0 or newer
- On Windows: [RTools](http://cran.r-project.org/bin/windows/Rtools/) (instructions for [setting up the R environment](https://ohdsi.github.io/Hades/rSetup.html))
- [Java](http://java.com)
- Suggested: 25 GB of free disk space

## Installing the Package
Install the IBD characterization package using either of the following methods:

- **renv (RECOMMENDED)**: To install the IBD characterization package along with all its dependencies in an encapsulated environment (and leaving your main `R` unchanged), run the code in [extras/renvInitScr.R](./extras/renvInitScr.R) or follow the instructions [here](https://github.com/ohdsi-studies/RanitidineCancerRisk/blob/master/StudyPackageSetup.md).


- **GitHub**: To install the package directly from GitHub (you may need to create a Personal Access Token, see instructions [here](https://ohdsi.github.io/Hades/installingHades.html)), open an `R` or `RStudio` console and run: 
````
install.packages("devtools")
devtools::install_github("ohdsi-studies/IbdCharacterization")
````
- **Zip file**: To preserve the GitHub directory structure, download the repository [zip file](https://github.com/ohdsi-studies/IbdCharacterization/archive/master.zip), copy it into your `R` or `RStudio` environment, and unzip it. Then double click on IbdCharacterization.Rproj to open it in R Studio, switch to the Build View and hit Install and Restart. For more details, see [The Book of OHDSI](https://ohdsi.github.io/TheBookOfOhdsi/PopulationLevelEstimation.html#running-the-study-package).

## Running the Study
1) Edit `.Renviron` to include the parameters used to connect to your database server (for more information see http://ohdsi.github.io/DatabaseConnector/); for example: 
````
DBMS = "postgresql"
DB_SERVER = "database.server.com"
DB_PORT = 5432
DB_USER = "database_user_name "
DB_PASSWORD = "your_secret_password"
PATH_TO_DB_DRIVER = "C:\temp\jdbcDrivers"
````

2) Edit `extras/CodeToRun.R` to show your database info (db ID, name, and description; CDM schema; cohort schema and tables) and output folder location, as follows: 
```` 
# Details specific to the database:
databaseId <- "<dbId>"
databaseName <- "<dbName>"
databaseDescription <- "<dbDesc>"

# Details for connecting to the CDM and storing the results
outputFolder <- file.path("D:/results/IbdCharacterization/Runs", databaseId)
cdmDatabaseSchema <- "<cdmDbSchema>"
cohortDatabaseSchema <- "<cohortDbSchema>"
cohortTable <- paste0("IbdCharacterization_", databaseId)
cohortStagingTable <- paste0(cohortTable, "_stg")
featureSummaryTable <- paste0(cohortTable, "_smry")
````
3) Run `extras/CodeToRun.R` to first generate diagnostics info for the Crohn's disease and ulcerative colitis cohorts, then extract the characterization statistics. Once done, you can review cohort diagnostics and characterization using the corresponding shiny apps. 

4) Upload the result files to OHDSI SFTP server (more info to come)
