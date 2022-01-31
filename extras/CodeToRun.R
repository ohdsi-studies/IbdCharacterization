# *******************************************************
# -----------------INSTRUCTIONS -------------------------
# *******************************************************
#
#-----------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------
# This CodeToRun.R is provided as an example of how to run this study package.
# Below you will find 2 sections: the 1st is for installing the dependencies 
# required to run the study and the 2nd for running the package.
#
# The code below makes use of R environment variables (denoted by "Sys.getenv(<setting>)") to 
# allow for protection of sensitive information. If you'd like to use R environment variables stored
# in an external file, this can be done by creating an .Renviron file in the root of the folder
# where you have cloned this code. For more information on setting environment variables please refer to: 
# https://stat.ethz.ch/R-manual/R-devel/library/base/html/readRenviron.html
#
#
# Below is an example .Renviron file's contents: (please remove)
# the "#" below as these too are interprted as comments in the .Renviron file:
#
#    DBMS = "postgresql"
#    DB_SERVER = "database.server.com"
#    DB_PORT = 5432
#    DB_USER = "database_user_name_goes_here"
#    DB_PASSWORD = "your_secret_password"
#    USE_SUBSET = FALSE
#
# The following describes the settings
#    DBMS, DB_SERVER, DB_PORT, DB_USER, DB_PASSWORD := These are the details used to connect
#    to your database server. For more information on how these are set, please refer to:
#    http://ohdsi.github.io/DatabaseConnector/
#
#    USE_SUBSET = TRUE/FALSE. When set to TRUE, this will allow for runnning this package with a 
#    subset of the cohorts/features. This is used for testing. PLEASE NOTE: This is only enabled
#    by setting this environment variable.
#
# Once you have established an .Renviron file, you must restart your R session for R to pick up these new
# variables. 
#
# In section 2 below, you will also need to update the code to use your site specific values. Please scroll
# down for specific instructions.
#-----------------------------------------------------------------------------------------------
#
# 
# *******************************************************
# SECTION 1: Make sure to install all dependencies (not needed if already done) -------------------------------
# *******************************************************
# 
# Prevents errors due to packages being built for other R versions: 
Sys.setenv("R_REMOTES_NO_ERRORS_FROM_WARNINGS" = TRUE)
# 
# First, it probably is best to make sure you are up-to-date on all existing packages.
# Important: This code is best run in R, not RStudio, as RStudio may have some libraries
# (like 'rlang') in use.
#update.packages(ask = "graphics")

# When asked to update packages, select '1' ('update all') (could be multiple times)
# When asked whether to install from source, select 'No' (could be multiple times)
#install.packages("devtools")
#devtools::install_github("ohdsi-studies/IbdCharacterization")

# *******************************************************
# SECTION 2: Running the package -------------------------------------------------------------------------------
# *******************************************************
library(IbdCharacterization)

dbConnectorVersionStr <- as.character(utils::packageVersion("DatabaseConnector"))[[1]]
dbConnectorVersion <- as.integer(strsplit(dbConnectorVersionStr, split="[.]")[[1]][1])

# Details for connecting to the server:
user <- if (Sys.getenv("DB_USER") == "") NULL else Sys.getenv("DB_USER")
password <- if (Sys.getenv("DB_PASSWORD") == "") NULL else Sys.getenv("DB_PASSWORD")
dbms <- Sys.getenv("DBMS")
server <- Sys.getenv("DB_SERVER")
port <- Sys.getenv("DB_PORT")
extraSettings <- if (Sys.getenv("DB_EXTRA_SETTINGS") == "") NULL else Sys.getenv("DB_EXTRA_SETTINGS")

connecionParams <- list(dbms = dbms,
                        server = server,
                        user = user,
                        password = password,
                        port = port,
                        extraSettings = extraSettings)

if (dbConnectorVersion >= 4) {
  pathToDriver <- if (Sys.getenv("PATH_TO_DB_DRIVER") == "") NULL else Sys.getenv("PATH_TO_DB_DRIVER")
  connecionParams <- c(connecionParams, list(pathToDriver = pathToDriver))
}

connectionDetails <- do.call(DatabaseConnector::createConnectionDetails, connecionParams)

#-----------------------------------------------------------------------------------------------
# Instructions for the remaining variables
#-----------------------------------------------------------------------------------------------
# 
# - oracleTempSchema := If using Oracle, what is the schema to use. Please see http://ohdsi.github.io/DatabaseConnector/ for more details.
# - databaseId := The database identifier to use for reporting results; please report to study lead
# - databaseName := The full name of your database
# - databaseDescription := A full description of your database.
# - outputFolder := The file path where the results of the study are placed.
# - cdmDatabaseSchema := The database schema where the OMOP CDM data exists. In the case of SQL Server, this should be the database + schema.
# - cohortDatabaseSchema := The database schema where the cohort data is created. The account specified as DB_USER must have full rights to that schema to create/drop tables
# - cohortTable := The name of the table to use the cohorts for the study
# - cohortStagingTable := The name of the table used to stage the cohorts used in this study
# - featureSummaryTable := The name of the table to hold the feature summary for this study
# - minCellCount := Aggregate stats that yield a value < minCellCount are censored in the output
# - cohortIdsToExcludeFromExecution := A vector of cohort IDs to exclude from generation in the study. This is useful if a particular cohort is problematic in your environment.
# - cohortIdsToExcludeFromResultsExport := A vector of cohort IDs to exclude from the export of the study. This is useful when you'd like to still generate the cohort, evaluate the results but do not want to share the cohort. 
#                                         The default is NULL so that all output generated will be available for review. Use the "exportResults" function in this package
#                                         to further refine the exported results to share with the study lead.
# - useBulkCharacterization := When set to TRUE, this will attempt to do all of the characterization operations for the whole 
#                              study via SQL vs sequentially per cohort and time window. This is recommended if your DB platform is 
#                              robust to perform this type of operation. Best to test this using the USE_SUBSET option to test.
# - cohortGroups := Optional parameter that allows you to specify which cohorts to use when running the study or diagnostics. By default
#                   both function will run using all cohorts for the study. For diagnostics, you may specify a vector with 1 or more
#                   of the following values: c("IBD", "CD", "UC", "strata", and "feature"). The runStudy function allows for 
#                   the specification of c("IBD", "CD", "UC"). 
#-----------------------------------------------------------------------------------------------

# For Oracle: define a schema that can be used to emulate temp tables:
oracleTempSchema <- NULL

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
minCellCount <- 5
useBulkCharacterization <- TRUE
cohortIdsToExcludeFromExecution <- c()
cohortIdsToExcludeFromResultsExport <- NULL

# For uploading the results. You should have received the key file from the study coordinator:
# keyFileName <- "E:/IbdCharacterization/study-data-site-ibd.dat"
# userName <- "study-data-site-ibd"

# Run cohort diagnostics -----------------------------------
runCohortDiagnostics(
	connectionDetails = connectionDetails,
    cdmDatabaseSchema = cdmDatabaseSchema,
    cohortDatabaseSchema = cohortDatabaseSchema,
    cohortStagingTable = cohortStagingTable,
    oracleTempSchema = oracleTempSchema,
    cohortIdsToExcludeFromExecution = cohortIdsToExcludeFromExecution,
    exportFolder = outputFolder,
    cohortGroupNames = c("CD", "UC"), # Optional - will use all groups ("IBD", "CD", "UC", "strata", "feature") by default
    databaseId = databaseId,
    databaseName = databaseName,
    databaseDescription = databaseDescription,
    minCellCount = minCellCount)

# Use the next command to review cohort diagnostics and replace "ibd" with
# one of these options: "IBD", "CD", "UC", "strata", "feature"
# diagnosticsFolder <- file.path(outputFolder, "diagnostics", "UC")
# preMergeDiagnosticsFiles(diagnosticsFolder)
# CohortDiagnostics::launchDiagnosticsExplorer(diagnosticsFolder)

# When finished with reviewing the diagnostics, use the next command
# to upload the diagnostic results
#uploadDiagnosticsResults(outputFolder, keyFileName, userName)

# Use this to run the study. The results will be stored in a zip file called 
# 'Results_<databaseId>.zip in the outputFolder. 
runStudy(connectionDetails = connectionDetails,
         cdmDatabaseSchema = cdmDatabaseSchema,
         cohortDatabaseSchema = cohortDatabaseSchema,
         cohortStagingTable = cohortStagingTable,
         cohortTable = cohortTable,
         featureSummaryTable = featureSummaryTable,
         oracleTempSchema = cohortDatabaseSchema,
         exportFolder = outputFolder,
         databaseId = databaseId,
         databaseName = databaseName,
         databaseDescription = databaseDescription,
         # cohortGroups = c("IBD", "CD", "UC"), # Optional - will use all groups by default
         cohortIdsToExcludeFromExecution = cohortIdsToExcludeFromExecution,
         cohortIdsToExcludeFromResultsExport = cohortIdsToExcludeFromResultsExport,
         incremental = TRUE,
         useBulkCharacterization = useBulkCharacterization,
         minCellCount = minCellCount) 



# Use the next set of commands to compress results
# and view the output.
#preMergeResultsFiles(outputFolder)
#launchShinyApp(outputFolder)

# When finished with reviewing the results, use the next command
# upload study results to OHDSI SFTP server:
# uploadStudyResults(outputFolder, keyFileName, userName)
