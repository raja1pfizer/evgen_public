server <- function(input, output, session) {

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
      cli::cli_alert_danger(sprintf("Failed to load module %s", module$tabName))
      shiny::showNotification(
        paste0("Error loading module: ", err),
        type = "error"
      )
    })

  }

  output$appLogo <- shiny::renderImage({
    src <- here::here('www', config$appLogo)
    list(src = src,
         alt = "App Logo")
  },
  deleteFile = FALSE)

  output$copyright <- shiny::renderUI({
    shiny::HTML(sprintf("  <small> &copy; </small> %s", format(Sys.Date(), "%Y")))
  })

}
