
bowViewer <- function(id = "bow", config) {
  ns <- shiny::NS(id)


  bslib::layout_columns(
    shiny::div(
      filterFormViewer(),
      class = "filter-form-container"
    ),
    shiny::div(
      shiny::uiOutput(outputId = ns("bowSummary")),
      shiny::br(),
      shiny::fluidRow(
        shiny::column(
          width = 4,
          shiny::uiOutput(outputId = ns("summaryStats"))
        ),
        shiny::column(
          width = 8,
          shiny::uiOutput(outputId = ns("studyVolumeObject"))
        )
      ),
      shiny::uiOutput(outputId = ns("bowTableObject")
      )
    ),
    col_widths = c(3, -1, 8)
  )

}


bowServer <- function(id = "bow", connection, config) {

  moduleServer <- shiny::moduleServer(
    id = id,
    function(input, output, session) {

      ns <- session$ns

      bowData <- .getDashboardData(connection = connection)

      bowDataReactive <- filterFormServer(df = bowData,
                                          formSpecification = .filterableFields)

      output$bowSummary <- shiny::renderUI({
        shiny::div(
          shiny::h2("CMAO Book of Work"),
          shiny::p("This report will allow you to explore the studies supported (funded and/or operationalized) by Medical Affairs."),
          shiny::p("The report includes Pfizer sponsored studies, research collaborations, investigator sponsored reserach and general research grants. Pfizer sponsored studies are included if they're listed as sponsored by the Commercial/legacy PBG organization. Research collaborations, ISRs and general research are included if the funding organization is one of the business units (ex: Oncology BU, Vaccines BU). Interventional studies under CT02 and any studies known to be operationalized by Safety Surveillance Research (SSR) or Global Medical Epidemiology (GME) are excluded."),
          shiny::p(sprintf("Data last refreshed: %s",
                           .getLastRefreshDate()))
        )
      })

      output$summaryStats <- shiny::renderUI({
        shiny::div(
          shiny::h5("Summary Statistics"),
          shiny::p("Total number of studies: ", nrow(bowDataReactive())),
          shiny::br(),
          shiny::p("By Country Priority"),
          shiny::tags$ul(
            shiny::tags$li("United States: ", .getUsStudyCount(bowDataReactive())),
            shiny::tags$li("International Priority: ", .getInternationalPriorityStudyCount(bowDataReactive())),
            shiny::tags$li("Anchor Markets: ", .getAnchorMarketStudyCount(bowDataReactive())),
            shiny::tags$li("All Other Countries: ", .getOtherCountryStudyCount(bowDataReactive()))
          ),
          shiny::br(),
          shiny::p("By Asset Priority"),
          shiny::tags$ul(
            shiny::tags$li("Priority Asset: ", .getPriorityAssetStudyCount(bowDataReactive())),
            shiny::tags$li("Launch Priority: ", .getLaunchPriorityStudyCount(bowDataReactive())),
            shiny::tags$li("Tier 1 Research Priority: ", .getTier1ResearchPriorityStudyCount(bowDataReactive())),
            shiny::tags$li("Tier 2 Research Priority: ", .getTier2ResearchPriorityStudyCount(bowDataReactive())),
            shiny::tags$li("All Other Assets: ", .getOtherAssetStudyCount(bowDataReactive())),
            shiny::tags$li("No Pfizer Drug: ", .getNoPfizerDrugStudyCount(bowDataReactive()))
          )
        )
      })

      output$studyVolumeObject <- shiny::renderUI({
        shiny::div(
          shiny::h5("Studies by Category"),
          plotly::plotlyOutput(outputId = ns("studyVolumePlot"))
        )
      })

      output$studyVolumePlot <- plotly::renderPlotly({
        #TODO: remove normalization below for favor elsewhere
        plotData <- bowDataReactive() |>
          dplyr::group_by(.data$HARMONIZEDCATEGORY) |>
          dplyr::summarize(Count = dplyr::n())

        p <- plotData |>
          ggplot2::ggplot() +
          ggplot2::aes(x = HARMONIZEDCATEGORY, y = Count) +
          ggplot2::geom_bar(stat = "identity", fill = "#0000C9") +
          ggplot2::theme_minimal() +
          ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 45, hjust = 1)) +
          ggplot2::labs(title = "",
                        x = "Category",
                        y = "Count")

        p <- plotly::ggplotly(p)

        p

      })

      output$bowTableObject <- shiny::renderUI({
        bslib::card(
          bslib::card_header("Study List"),
          evgenTableViewer(id = ns("bowtable")),
          bslib::card_footer(
            shiny::downloadButton(outputId = "downloadData", label = "Download Data")
          )
        )
      })

      evgenTableServer(id = "bowtable",
                        data = bowDataReactive,
                        columns = makeReactableColDefsFromList(columnsSpecification = .mainStudyTableColumnSpecifications),
                        striped = TRUE,
                        searchable = TRUE,
                        bordered = TRUE,
                        sortable = FALSE,
                        highlight = TRUE,
                        showPageSizeOptions = TRUE,
                        paginationType = "jump",
                        defaultColDef = reactable::colDef(
                          minWidth = 200,
                          headerStyle = list(background = "#0000C9", color = "white"),
                          align = "left"
                        ))

      output$downloadData <- downloadHandler(
        filename = function() {
          paste("bow-data-", Sys.Date(), ".xlsx", sep = "")
        },
        content = function(file) {
          exportData <- bowDataReactive() |>
            formatTablePerSpecification(columnsSpecification = .mainStudyTableColumnSpecifications)
          writexl::write_xlsx(exportData, file)
        }
      )


    })

  return(moduleServer)
}
