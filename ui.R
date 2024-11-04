ui <- bslib::page_fluid(
  if (!is.null(config$globalCssFile)) {
    shiny::includeCSS(
      here::here('www', config$globalCssFile)
    )
  },
  title = config$appBrowserTitle,
  theme = bslib::bs_theme(
    version = config$bootstrapVersion,
    bootswatch = config$appTheme,
    base_font = bslib::font_collection(bslib::font_google(config$appFont,
                                                          local = FALSE)),
    font_scale = config$appFontScale
  ),
  do.call(
    bslib::navset_card_pill,
    c(
      lapply(
        config$shinyModules,
        function(module) {
          if (!is.null(module$shinyModulePackage)) {
            uiFunction <- parse(text = paste0(module$shinyModulePackage,"::" ,module$uiFunction))
          } else {
            uiFunction <- module$uiFunction
          }
          bslib::nav_panel(
            title = module$tabName,
            icon = shiny::icon(module$icon),
            get(uiFunction)(id = module$id,
                            config = module)
          )
        }
      ),
      if (!is.null(config$navLinks)) {
        list(
          bslib::nav_menu(
            title = "Links",
            do.call(
              bslib::nav_item,
              lapply(
                config$navLinks,
                function(link) {
                  return(
                    shiny::tags$a(
                      shiny::icon(link$icon),
                      link$name,
                      href = link$url,
                      target = "_blank")
                  )}
              )
            )
          )
        )
      },
      id = "main-tabs",
      title = list(shiny::div(
        if (!is.null(config$appLogo) && !config$appLogo == "") {
          shiny::imageOutput(outputId = "appLogo")
        },
        shiny::div(
          config$appTitle,
          class = "app-title"
        )
      ))
    )
  ),
  shiny::tags$footer(
    shiny::h6(
      "A Pfizer RWE Platforms Digital Product",
      shiny::uiOutput(outputId = "copyright")
    )
  )
)
