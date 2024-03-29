% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/Shiny.R
\name{preMergeDiagnosticsFiles}
\alias{preMergeDiagnosticsFiles}
\title{Premerge Shiny diagnostics files}
\usage{
preMergeDiagnosticsFiles(dataFolder)
}
\arguments{
\item{dataFolder}{folder where the exported zip files for the diagnostics are stored. Use
the \code{\link{runCohortDiagnostics}} function to generate these zip files.
Zip files containing results from multiple databases can be placed in the same
folder.}
}
\description{
If there are many diagnostics files, starting the Shiny app may take a very long time. This function
already does most of the preprocessing, increasing loading speed.

The merged data will be stored in the same folder, and will automatically be recognized by the Shiny app.
}
