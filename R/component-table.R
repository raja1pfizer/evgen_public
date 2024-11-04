
makeReactableColDefsFromList <- function(columnsSpecification) {

  checkmate::assertList(columnsSpecification)

  columns <- lapply(
    seq_along(columnsSpecification),
    function(i) {
      col <- .reconcileFunctionFormals(
        fun = reactable::colDef,
        aList = columnsSpecification[[i]],
        warnOnExtraArgs = FALSE,
        replaceNullValuesWithDefault = TRUE)
      return(do.call(reactable::colDef, col))
    }
  )

  names(columns) <- names(columnsSpecification)
  return(columns)
}



formatTablePerSpecification <- function(data, columnsSpecification) {

  assertCollection <- checkmate::makeAssertCollection()
  checkmate::assert(
    .checkReactive(data),
    checkmate::checkDataFrame(data),
    combine = "or",
    add = assertCollection
  )
  checkmate::assertList(columnsSpecification, add = assertCollection)
  checkmate::reportAssertions(collection = assertCollection)

  formattedData <- NULL
  if (.isReactive(data)) {
    formattedData <- data()
  } else {
    formattedData <- data
  }

  columnsOfInterest <- names(columnsSpecification)

  newColumnNames <- columnsSpecification |>
    purrr::map(~ .x$name)

  formattedData <- formattedData |>
    dplyr::select(dplyr::any_of(columnsOfInterest)) |>
    dplyr::rename_with(~ unlist(newColumnNames),
                       dplyr::any_of(names(newColumnNames)))

  return(formattedData)
}



evgenTableViewer <- function(id = "my-table") {

  checkmate::assertCharacter(id)

  ns <- shiny::NS(id)

  shiny::div(
    reactable::reactableOutput(ns("table")),
  )
}



evgenTableServer <- function(id = "my-table",
                             data,
                             omitUnspecifiedColumns = TRUE,
                             ...) {

  assertCollection <- checkmate::makeAssertCollection()
  checkmate::assertCharacter(id, add = assertCollection)
  checkmate::assert(
    .checkReactive(data),
    checkmate::checkDataFrame(data),
    combine = "or",
    add = assertCollection
  )
  checkmate::assertLogical(omitUnspecifiedColumns, add = assertCollection)
  checkmate::reportAssertions(collection = assertCollection)


  moduleServer <- shiny::moduleServer(
    id = id,
    function(input, output, session) {

    output$table <- reactable::renderReactable({
      if (.isReactive(data)) {
        tableData <- data()
      } else {
        tableData <- data
      }

      if (exists("columns", envir = .GlobalEnv) && omitUnspecifiedColumns) {
        tableData <- tableData |>
          dplyr::select(dplyr::any_of(names(columns)))
      }

      reactable::reactable(
        data = tableData,
        ...
      )
    })
  })

  return(moduleServer)
}
