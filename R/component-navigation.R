
navLinksViewer <- function(id = "nav-links", title = "Links", config) {


  assertCollection <- checkmate::makeAssertCollection()
  checkmate::assertCharacter(id, add = assertCollection)
  checkmate::assertCharacter(title, add = assertCollection)
  checkmate::reportAssertions(collection = assertCollection)

  ns <- shiny::NS(id)

  return(
    bslib::nav_menu(
      title = title,
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
}


navLinksServer <- function(id, config) {
  moduleServer <- shiny::moduleServer(
    id = id,
    function(input, output, session) {

    }
  )

  return(moduleServer)
}
