dataFlowAndUpdatesViewer <- function(id = "data", config) {
  ns <- shiny::NS(id)

  shiny::div(
    shiny::h2("Data Flow and Updates"),
    shiny::p(
      "Data included in this report are initially sourced from Pfizer's systems of record. Those include:"),
    shiny::tags$ul(
      shiny::tags$li("Pfizer sponsored studies (ex: CT24, CT45) are pulled from Siebel, Pfizer's Corporate Clinical Trial Management System and pulled in via GPDIP"),
      shiny::tags$li("Research Collaborations for non-regulatory purposes (RC01) are pulled from Cybergrants"),
      shiny::tags$li("Investigator sponsored research and general research grants (both part of GNT01) are pulled from Cybergrants")
    ),
    shiny::p("These data are then pulled from the systems of record into the Evidence Ctalog that is part of the Knowledge and Insights Mangagement System (KIMS). In KIMS, expert users from clinical affairs and operations are able to curate the data, adding additional information including the group operationalizing the study, the study team and information about study transition plans."),
    shiny::p("The data from the Evidence Catalog is then pulled into this report."),
    shiny::p("Both the Evidence Catalog and the data for this Book of Work is updated on a daily basis.")
  )
}



dataFlowAndUpdatesServer <- function(id = "data", connection, config) {

  moduleServer <- shiny::moduleServer(
    id = id,
    function(input, output, session) {

    })

  return(moduleServer)
}
