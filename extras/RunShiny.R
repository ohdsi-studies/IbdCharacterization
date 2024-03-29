# install.packages("shiny")
# install.packages("shinydashboard")
# install.packages("DT")
# install.packages("VennDiagram")
# install.packages("htmltools")
dataFolder <- "E:/IbdCharacterization/MDCR_Bail_test"
appDir <- system.file("shiny", "CharacterizationExplorer", package = "IbdCharacterization", mustWork = TRUE)
shinySettings <- list(dataFolder = dataFolder)
.GlobalEnv$shinySettings <- shinySettings
on.exit(rm(shinySettings, envir = .GlobalEnv))
shiny::runApp(appDir)
