# Copyright 2022 Observational Health Data Sciences and Informatics
#
# This file is part of IbdCharacterization
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Format and check code ---------------------------------------------------
OhdsiRTools::formatRFolder()
OhdsiRTools::checkUsagePackage("IbdCharacterization")
OhdsiRTools::updateCopyrightYearFolder()

# Create manual -----------------------------------------------------------
unlink("extras/IbdCharacterization.pdf")
shell("R CMD Rd2pdf ./ --output=extras/IbdCharacterization.pdf")

pkgdown::build_site()

# AGS: Had to copy these functions from OhdsiRWebAPI since we're using
# the cohortId for the SQL file names
# Insert cohort definitions from ATLAS into package -----------------------
insertCohortDefinitionSetInPackage <- function(fileName = "inst/settings/CohortsToCreate.csv",
                                               baseUrl,
                                               jsonFolder = "inst/cohorts",
                                               sqlFolder = "inst/sql/sql_server",
                                               rFileName = "R/CreateCohorts.R",
                                               insertTableSql = TRUE,
                                               insertCohortCreationR = TRUE,
                                               generateStats = FALSE,
                                               packageName) {
  errorMessage <- checkmate::makeAssertCollection()
  checkmate::assertLogical(insertTableSql, add = errorMessage)
  checkmate::assertLogical(insertCohortCreationR, add = errorMessage)
  checkmate::assertLogical(generateStats, add = errorMessage)
  checkmate::assertScalar(packageName, add = errorMessage)
  checkmate::assertCharacter(packageName, add = errorMessage)
  checkmate::reportAssertions(errorMessage)
  
  if (insertCohortCreationR && !insertTableSql)
    stop("Need to insert table SQL in order to generate R code")
  if (insertCohortCreationR && generateStats && jsonFolder != "inst/cohorts")
    stop("When generating R code and generating stats, the jsonFolder must be 'inst/cohorts'")
  if (insertCohortCreationR && sqlFolder != "inst/sql/sql_server")
    stop("When generating R code, the sqlFolder must be 'inst/sql/sql_server'")
  if (insertCohortCreationR && !grepl("inst", fileName))
    stop("When generating R code, the input CSV file must be in the inst folder.")
  
  cohortsToCreate <- readr::read_csv(fileName, col_types = readr::cols())
  cohortsToCreate <- cohortsToCreate[cohortsToCreate$atlasId > 0, ]
  
  # Inserting cohort JSON and SQL
  for (i in 1:nrow(cohortsToCreate)) {
    writeLines(paste("Inserting cohort:", cohortsToCreate$name[i]))
    insertCohortDefinitionInPackage(cohortId = cohortsToCreate$atlasId[i],
                                    localCohortId = cohortsToCreate$cohortId[i],
                                    name = cohortsToCreate$name[i],
                                    baseUrl = baseUrl,
                                    jsonFolder = jsonFolder,
                                    sqlFolder = sqlFolder,
                                    generateStats = generateStats)
  }
  
  # Insert SQL to create empty cohort table
  if (insertTableSql) {
    writeLines("Creating SQL to create empty cohort table")
    .insertSqlForCohortTableInPackage(statsTables = generateStats, sqlFolder = sqlFolder)
  }
  
  # Store information on inclusion rules
  if (generateStats) {
    writeLines("Storing information on inclusion rules")
    rules <- .getCohortInclusionRules(jsonFolder)
    rules <- merge(rules, data.frame(cohortId = cohortsToCreate$cohortId,
                                     cohortName = cohortsToCreate$name))
    csvFileName <- file.path(jsonFolder, "InclusionRules.csv")
    write.csv(rules, csvFileName, row.names = FALSE)
    writeLines(paste("- Created CSV file:", csvFileName))
  }
  
  # Generate R code to create cohorts
  if (insertCohortCreationR) {
    writeLines("Generating R code to create cohorts")
    templateFileName <- system.file("CreateCohorts.R", package = "ROhdsiWebApi", mustWork = TRUE)
    rCode <- readChar(templateFileName, file.info(templateFileName)$size)
    rCode <- gsub("#CopyrightYear#", format(Sys.Date(), "%Y"), rCode)
    rCode <- gsub("#packageName#", packageName, rCode)
    libPath <- gsub(".*inst[/\\]", "", fileName)
    libPath <- gsub("/|\\\\", "\", \"", libPath)
    rCode <- gsub("#fileName#", libPath, rCode)
    if (generateStats) {
      rCode <- gsub("#stats_start#", "", rCode)
      rCode <- gsub("#stats_end#", "", rCode)
    } else {
      rCode <- gsub("#stats_start#.*?#stats_end#", "", rCode)
    }
    fileConn <- file(rFileName)
    writeChar(rCode, fileConn, eos = NULL)
    close(fileConn)
    writeLines(paste("- Created R file:", rFileName))
  }
}

insertCohortDefinitionInPackage <- function(cohortId,
                                            localCohortId,
                                            name = NULL,
                                            jsonFolder = "inst/cohorts",
                                            sqlFolder = "inst/sql/sql_server",
                                            baseUrl,
                                            generateStats = FALSE) {
  errorMessage <- checkmate::makeAssertCollection()
  checkmate::assertInt(cohortId, add = errorMessage)
  checkmate::assertLogical(generateStats, add = errorMessage)
  checkmate::reportAssertions(errorMessage)
  
  object <- ROhdsiWebApi::getCohortDefinition(cohortId = cohortId, 
                                              baseUrl = baseUrl)
  if (is.null(name)) {
    name <- object$name
  }
  if (!file.exists(jsonFolder)) {
    dir.create(jsonFolder, recursive = TRUE)
  }
  jsonFileName <- file.path(jsonFolder, paste(localCohortId, "json", sep = "."))
  json <- RJSONIO::toJSON(object$expression, digits = 23, pretty = TRUE)  
  SqlRender::writeSql(sql = json, targetFile = jsonFileName)
  writeLines(paste("- Created JSON file:", jsonFileName))
  
  # Fetch SQL
  sql <- ROhdsiWebApi::getCohortSql(baseUrl = baseUrl, cohortDefinition = object, generateStats = generateStats)
  if (!file.exists(sqlFolder)) {
    dir.create(sqlFolder, recursive = TRUE)
  }
  sqlFileName <- file.path(sqlFolder, paste(localCohortId, "sql", sep = "."))
  SqlRender::writeSql(sql = sql, targetFile = sqlFileName)
  writeLines(paste("- Created SQL file:", sqlFileName))
}

cohortGroups <- readr::read_csv("inst/settings/CohortGroups.csv", col_types=readr::cols())
for (i in 1:nrow(cohortGroups)) {
  ParallelLogger::logInfo("* Importing cohorts in group: ", cohortGroups$cohortGroup[i], " *")
  insertCohortDefinitionSetInPackage(fileName = file.path("inst/", cohortGroups$fileName[i]),
                                     baseUrl = Sys.getenv("baseUrl"),
                                     insertTableSql = FALSE,
                                     insertCohortCreationR = FALSE,
                                     generateStats = FALSE,
                                     packageName = "IbdCharacterization")
}
unlink("inst/cohorts/InclusionRules.csv")

# Create the corresponding diagnostic file 
for (i in 1:nrow(cohortGroups)) {
  ParallelLogger::logInfo("* Creating diagnostics settings file for: ", cohortGroups$cohortGroup[i], " *")
  cohortsToCreate <- readr::read_csv(file.path("inst/", cohortGroups$fileName[i]), col_types = readr::cols())
  cohortsToCreate$name <- cohortsToCreate$cohortId
  readr::write_csv(cohortsToCreate, file.path("inst/settings/diagnostics/", basename(cohortGroups$fileName[i])))
}


# Create the list of combinations of T, TwS, TwoS for the combinations of strata ----------------------------
settingsPath <- "inst/settings"
useSubset <- as.logical(Sys.getenv("USE_SUBSET"))
if (useSubset) {
  settingsPath <- file.path(settingsPath, "subset/")
}
ibdCohorts <- read.csv(file.path(settingsPath, "CohortsToCreateIBD.csv"))
cdCohorts <- read.csv(file.path(settingsPath, "CohortsToCreateCD.csv"))
ucCohorts <- read.csv(file.path(settingsPath, "CohortsToCreateUC.csv"))

bulkStrata <- read.csv(file.path(settingsPath, "BulkStrata.csv"))
atlasCohortStrata <- read.csv(file.path(settingsPath, "CohortsToCreateStrata.csv"))
featureCohorts <- read.csv(file.path(settingsPath, "CohortsToCreateFeature.csv"))


# Ensure all of the IDs are unique
allCohortIds <- c(ibdCohorts[,match("cohortId", names(ibdCohorts))], 
                  cdCohorts[,match("cohortId", names(cdCohorts))],
                  ucCohorts[,match("cohortId", names(ucCohorts))],
                  bulkStrata[,match("cohortId", names(bulkStrata))],
                  atlasCohortStrata[,match("cohortId", names(atlasCohortStrata))],
                  featureCohorts[,match("cohortId", names(featureCohorts))])
allCohortIds <- sort(allCohortIds)

totalRows <- nrow(ibdCohorts) + nrow(cdCohorts) + nrow(ucCohorts) + nrow(bulkStrata) + nrow(atlasCohortStrata) + nrow(featureCohorts)
if (length(unique(allCohortIds)) != totalRows) {
  warning("There are duplicate cohort IDs in the settings files!")
}

# When necessary, use this to view the full list of cohorts in the study
fullCohortList <- rbind(ibdCohorts[,c("cohortId", "atlasId", "name")],
                        cdCohorts[,c("cohortId", "atlasId", "name")],
                        ucCohorts[,c("cohortId", "atlasId", "name")],
                        atlasCohortStrata[,c("cohortId", "atlasId", "name")],
                        featureCohorts[,c("cohortId", "atlasId", "name")])

fullCohortList <- fullCohortList[order(fullCohortList$cohortId),]

# Target cohorts
colNames <- c("name", "cohortId") # Use this to subset to the columns of interest
targetCohorts <- rbind(ibdCohorts, cdCohorts, ucCohorts)
targetCohorts <- targetCohorts[, match(colNames, names(targetCohorts))]
names(targetCohorts) <- c("targetName", "targetId")
# Strata cohorts
bulkStrata <- bulkStrata[, match(colNames, names(bulkStrata))]
bulkStrata$withStrataName <- paste("with", trimws(bulkStrata$name))
bulkStrata$inverseName <- paste("without", trimws(bulkStrata$name))
atlasCohortStrata <- atlasCohortStrata[, match(colNames, names(atlasCohortStrata))]
atlasCohortStrata$withStrataName <- paste("with", trimws(atlasCohortStrata$name))
atlasCohortStrata$inverseName <- paste("without", trimws(atlasCohortStrata$name))
strata <- rbind(bulkStrata, atlasCohortStrata)
names(strata) <- c("name", "strataId", "strataName", "strataInverseName")
# Get all of the unique combinations of target + strata
targetStrataCP <- do.call(expand.grid, lapply(list(targetCohorts$targetId, strata$strataId), unique))
names(targetStrataCP) <- c("targetId", "strataId")
targetStrataCP <- merge(targetStrataCP, targetCohorts)
targetStrataCP <- merge(targetStrataCP, strata)
targetStrataCP <- targetStrataCP[order(targetStrataCP$strataId, targetStrataCP$targetId),]
targetStrataCP$cohortId <- (targetStrataCP$targetId * 1000000) + (targetStrataCP$strataId*10)
tWithS <- targetStrataCP
tWithoutS <- targetStrataCP[targetStrataCP$strataId %in% atlasCohortStrata$cohortId, ]
tWithS$cohortId <- tWithS$cohortId + 1
tWithS$cohortType <- "TwS"
tWithS$name <- paste(tWithS$targetName, tWithS$strataName)
tWithoutS$cohortId <- tWithoutS$cohortId + 2
tWithoutS$cohortType <- "TwoS"
tWithoutS$name <- paste(tWithoutS$targetName, tWithoutS$strataInverseName)
targetStrataXRef <- rbind(tWithS, tWithoutS)

# For shiny, construct a data frame to provide details on the original cohort names
xrefColumnNames <- c("cohortId", "targetId", "targetName", "strataId", "strataName", "cohortType")
targetCohortsForShiny <- targetCohorts
targetCohortsForShiny$cohortId <- targetCohortsForShiny$targetId
targetCohortsForShiny$strataId <- 0
targetCohortsForShiny$strataName <- "All"
targetCohortsForShiny$cohortType <- "Target"
inverseStrata <- targetStrataXRef[targetStrataXRef$cohortType == "TwoS",]
inverseStrata$strataName <- inverseStrata$strataInverseName

shinyCohortXref <- rbind(targetCohortsForShiny[,xrefColumnNames], 
                         inverseStrata[,xrefColumnNames],
                         targetStrataXRef[targetStrataXRef$cohortType == "TwS",xrefColumnNames])
if (!useSubset) {
  readr::write_csv(shinyCohortXref, file.path("inst/shiny/IbdCharacterizationResultsExplorer", "cohortXref.csv"))
}

targetStrataXRef <- targetStrataXRef[,c("targetId","strataId","cohortId","cohortType","name")]

# Write out the final targetStrataXRef
readr::write_csv(targetStrataXRef, file.path(settingsPath, "targetStrataXref.csv"))  

# Store environment in which the study was executed -----------------------
OhdsiRTools::insertEnvironmentSnapshotInPackage("IbdCharacterization")

packageFiles <- list.files(path=".", recursive = TRUE)
if (!all(utf8::utf8_valid(packageFiles))) {
  print("Found invalid UTF-8 encoded files")
}