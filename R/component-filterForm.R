
.getOptionsFromField <- function(df, field, sorted = TRUE, withEmptyOption = TRUE) {
  vals <- unique(df[, field]) |>
    dplyr::pull(field)
  if (sorted)
    vals <- sort(vals)
  if (withEmptyOption &&
      !("" %in% vals))
    vals <- c("", vals)
  return(vals)
}

.getFieldDefaultFilters <- function(formSpecification, field) {
  stop("Deprecated...")
  element <- formSpecification |>
    purrr::keep(~ .$field == field)
  if (length(element) == 0)
    return(NULL)
  return(element[[1]]$defaultValues)
}


filterFormViewer <- function(id = "filter-form", inline = FALSE) {

  assertCollection <- checkmate::makeAssertCollection()
  checkmate::assertCharacter(id, add = assertCollection)
  checkmate::assertLogical(inline, add = assertCollection)
  checkmate::reportAssertions(collection = assertCollection)

  ns <- shiny::NS(id)

  return(
    shiny::uiOutput(outputId = ns("filterForm"))
  )
}


filterFormServer <- function(id = "filter-form",
                             df,
                             formSpecification,
                             withHeader = TRUE,
                             headerLevel = 6,
                             headerText = "Dashboard Filters",
                             centerHeader = TRUE,
                             withResetButton = TRUE,
                             resetButtonText = "Reset Filters",
                             resetButtonLocation = "bottom",
                             centerResetButton = TRUE,
                             callBack = NULL) {


  assertCollection <- checkmate::makeAssertCollection()
  checkmate::assertCharacter(id, add = assertCollection)
  checkmate::assertDataFrame(df, add = assertCollection)
  checkmate::assertList(formSpecification, add = assertCollection)
  checkmate::assertLogical(withHeader, add = assertCollection)
  checkmate::assertIntegerish(headerLevel, add = assertCollection, lower = 1, upper = 6)
  checkmate::assertCharacter(headerText, add = assertCollection)
  checkmate::assertLogical(centerHeader, add = assertCollection)
  checkmate::assertLogical(withResetButton, add = assertCollection)
  checkmate::assertCharacter(resetButtonText, add = assertCollection)
  checkmate::assertChoice(resetButtonLocation, c("top", "bottom"), add = assertCollection)
  checkmate::assertLogical(centerResetButton, add = assertCollection)
  checkmate::reportAssertions(collection = assertCollection)

  moduleServer <- shiny::moduleServer(
    id = id,
    function(input, output, session) {

      ns <- session$ns

      filteredReactiveData <- shiny::reactiveVal(value = df)

      lapply(seq_along(formSpecification),
             function (i) {
               field <- names(formSpecification)[[i]]
               x <- formSpecification[[i]]
               shiny::observeEvent(eval(parse(text = paste0('input$', field))), {
                 backingData <- filteredReactiveData()

                 backingData <- df
                 for (inputVar in names(input)) {
                   if (!is.null(input[[inputVar]]) &&
                       inputVar %in% names(formSpecification)) {
                     backingData <- backingData |>
                       dplyr::filter(
                         .data[[inputVar]] %in% input[[inputVar]]
                       )
                   }
                 }
                 filteredReactiveData(backingData)
               }, ignoreNULL = FALSE, ignoreInit = FALSE)
             }
      )

      #TODO: support non-categorical variables
      output$filterForm <- shiny::renderUI({

        formElements <- do.call(shiny::tagList,
                                lapply(
                                  seq_along(formSpecification),
                                  function(i) {
                                    field <- names(formSpecification)[[i]]
                                    x <- formSpecification[[i]]
                                    shiny::div(
                                      # if a tooltip is specified, add it
                                      if (!is.null(x$tooltip)) {
                                        bslib::tooltip(
                                          trigger = shiny::icon("circle-question"),
                                          x$tooltip,
                                          placement = "right",
                                          class = "form-tooltip",
                                        )
                                      },
                                      shiny::selectizeInput(
                                      inputId = ns(field),
                                      label = x$label,
                                      choices = .getOptionsFromField(df = df,
                                                                     field = field),
                                      selected = x$defaultValues,
                                      multiple = ifelse(is.null(x$multiple) || !x$multiple, FALSE, TRUE),
                                      options = list(
                                        placeholder = x$placeholder
                                      )
                                    )
                                    )
                                  })
        )
        form <- formElements

        if (withHeader) {
          style <- ifelse(centerHeader, "text-align: center;", "")
          form <- shiny::div(
            eval(parse(text = sprintf("shiny::h%d", headerLevel)))(headerText,
                                                                   style = style),
            form
          )
        }

        if (withResetButton) {
          buttonContainerStyle <- ifelse(centerResetButton, "display: flex; flex-direction: row; align-items: center; justify-content: center;", "")
          resetButton <- shiny::actionButton(
            inputId = ns("resetFilters"),
            label = resetButtonText,
            style = "background: #0000C9; color: white;"
          )
          if (resetButtonLocation == "top") {
            form <- shiny::div(
              shiny::div(
                resetButton,
                style = buttonContainerStyle
              ),
              form
            )
          } else if (resetButtonLocation == "bottom") {
            form <- shiny::div(
              form,
              shiny::div(
                resetButton,
                style = buttonContainerStyle
              )
            )
          }
        }

        return(form)
      })



      if (withResetButton) {
        shiny::observeEvent(input$resetFilters, {
          lapply(seq_along(formSpecification), function(i) {
            field <- names(formSpecification)[[i]]
            x <- formSpecification[[i]]
            shiny::updateSelectInput(
              session = session,
              inputId = field,
              choices = .getOptionsFromField(df = df,
                                             field = field),
              selected = x$defaultValues
            )
          })
        })
      }

      return(filteredReactiveData)
    })

  return(moduleServer)
}

