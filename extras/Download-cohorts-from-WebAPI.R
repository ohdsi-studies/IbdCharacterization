getCohortDefinitionExpression <- function(definitionId, baseUrl) {
  url <- paste(baseUrl, "cohortdefinition", definitionId, sep = "/")
  json <- httr::GET(url)
  httr::content(json)
}

