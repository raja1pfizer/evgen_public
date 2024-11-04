releaseNotesViewer <- function(id = "release-notes", config) {
  ns <- shiny::NS(id)

  #TODO: mechanism to pull this metadata in automatically
  shiny::div(
    shiny::h2("Release Notes"),
    shiny::p("Book of Work Release 2.0 (2024-09-24)"),
    shiny::tags$ul(
      shiny::tags$li("Replatforming of the application to an R-Shiny-based application"),
      shiny::tags$li("Omission of terminated studies from the scope of the default view"),
      shiny::tags$li("Harmonization of study status and study status details from source systems"),
      shiny::tags$li("Addition of a study status details filter")
    ),
    shiny::p("Book of Work Release 1.18 (2024-09-09)"),
    shiny::tags$ul(
      shiny::tags$li("Introduced automated data ingestion")
    ),
    shiny::p("Book of Work Release 1.17 (2024-06-18)"),
    shiny::p("The following updates were included:"),
    shiny::tags$ul(
      shiny::tags$li("somatrogon reclassified from internal medicine to rare disease"),
      shiny::tags$li("pegvisomant reclassified from interal medicine to rare disease"),
      shiny::tags$li("relugolix reclassified from internal medicine to oncology")
    ),
    shiny::p("Book of Work Release 1.15. (2024-05-29)"),
    shiny::p("The following updates were included:"),
    shiny::tags$ul(
      shiny::tags$li("Added Data Flow and Updates Page"),
      shiny::tags$li("Added Release Notes Page"),
      shiny::tags$li("Added Filter for \"Group Executing\" so that studies can be search according to which group is responsible for operations (ex; SSR, GME, RWE, etc)."),
      shiny::tags$li("Updated the titles for some filters"),
      shiny::tags$li("Improved the functionality of the country and asset filters so that when a selection is made in one filter, the options in every other filter are limited to what's available in the filtered dataset.")
    )
  )
}


releaseNotesServer <- function(id = "release-notes", connection, config) {

  moduleServer <- shiny::moduleServer(
    id = id,
    function(input, output, session) {

    })

  return(moduleServer)
}
