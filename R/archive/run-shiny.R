.filterOmittedModules <- function(config) {

  isIncludedModule <- function(e) {
    return(
      !("include" %in% names(e)) || e$include
    )
  }

  config$shinyModules <- config$shinyModules[sapply(config$shinyModules, isIncludedModule)]
  for (moduleId in 1:length(config$shinyModules)) {
    module <- config$shinyModules[[moduleId]]
    if (!("subModules" %in% names(module)) || length(module$subModules) == 0)
      next
    subModules <- module$subModules
    subModules <- subModules[sapply(subModules, isIncludedModule)]
    config$shinyModules[[moduleId]]$subModules <- subModules
  }
  return(config)

}


runShiny <- function(config = NULL, launch.browser = TRUE, test.mode = FALSE) {

  app <- evgenbowshiny::createShinyApp(config = config)

  shiny::runApp(app, launch.browser = launch.browser, test.mode = test.mode)
}


createShinyApp <- function(config = NULL) {
  if (is.null(config))
    config <- jsonlite::fromJSON(txt = system.file("config", "default-config.json", package = "evgenbowshiny"), simplifyDataFrame = FALSE)

  config <- .filterOmittedModules(config)

  connectionDetails <- DatabaseConnector::createConnectionDetails(
    dbms = "snowflake",
    connectionString = keyring::key_get("tmpConnectionString"),
    user = keyring::key_get("tmpUser"),
    password = keyring::key_get("tmpPassword")
  )

  app <- shiny::shinyApp(
    ui = evgenbowshiny::ui(config = config),
    server = evgenbowshiny::server(
      config = config,
      connectionDetails = connectionDetails
    )
  )

  return(app)
}
