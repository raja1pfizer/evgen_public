server <- function(config, connectionDetails) {
  moduleServer <- shiny::shinyServer(
    function(input, output, session) {


      connection <- .getDatabaseConnection(connectionDetails)
      # connection <- NULL

      on.exit(
        DatabaseConnector::disconnect(connection)
      )


      for (module in config$shinyModules) {
        argsList <- list(
          id = module$id,
          connection = connection,
          config = module
        )

        tryCatch({
          if (!is.null(module$shinyModulePackage)) {
            serverFunc <- parse(text = paste0(module$shinyModulePackage, "::", module$serverFunction))
          } else {
            serverFunc <- module$serverFunction
          }
          shiny::withProgress({
            do.call(
              what = eval(serverFunc),
              args = argsList
            )
          }, message = paste("Loading ", module$tabName))

        }, error = function(err) {
          ParallelLogger::logError("Failed to load module ", module$tabName)
          shiny::showNotification(
            paste0("Error loading module: ", err),
            type = "error"
          )
        })

      }

      output$appLogo <- shiny::renderImage({
        src <- system.file('www',
                           config$appLogo,
                           package = config$packageName)
        list(src = src,
             alt = "App Logo")
      },
      deleteFile = FALSE)

      output$copyright <- shiny::renderUI({
        shiny::HTML(sprintf("  <small> &copy; </small> %s", format(Sys.Date(), "%Y")))
      })

    })

  return(moduleServer)
}
