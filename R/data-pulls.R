
.getDatabaseConnection <- function(connectionDetails, withSessionAlter = TRUE) {
  #TODO: error handling
  #TODO: swap databaseconnector with evgenR package
  connection <- DatabaseConnector::connect(connectionDetails = connectionDetails)
  if (withSessionAlter)
    DatabaseConnector::executeSql(connection = connection,
                                  sql = "ALTER SESSION SET JDBC_QUERY_RESULT_FORMAT='JSON';")
  return(connection)
}

.getLastRefreshDate <- function(filePath = here::here("data",
                                                      "output"),
                                fileName = "last_load.date") {

  theFile <- here::here(filePath, fileName)
  if (file.exists(theFile)) {
    lastRefreshDate <- readr::read_lines(theFile)
  } else {
    lastRefreshDate <- NULL
  }

  return(lastRefreshDate)

}

.getDashboardData <- function(connection, tableName = "DEV_EVIDENCECATALOG") {

  # sql <- glue::glue("
  #   SELECT
  #     *
  #   FROM
  #     RWD_PROD.TEAM_EVGEN.{tableName};
  # ")
  #
  #
  # data <- DatabaseConnector::querySql(
  #   connection = connection,
  #   sql = sql
  # )

  data <- readr::read_csv("data/output/nis.csv")

  return(data)

}

.getUsStudyCount <- function(df) {
  return(
      df |>
      dplyr::filter(
        .data$UNITEDSTATES == "Yes"
      ) |>
      nrow()
  )
}

.getInternationalPriorityStudyCount <- function(df) {
  return(
    df |>
      dplyr::filter(
        .data$INTERNATIONALPRIORITY == "Yes"
      ) |>
      nrow()
  )
}

.getAnchorMarketStudyCount <- function(df) {
  return(
    df |>
      dplyr::filter(
        .data$ANCHORMARKET == "Yes"
      ) |>
      nrow()
  )
}

.getOtherCountryStudyCount <- function(df) {
  return(
    df |>
      dplyr::filter(
        .data$UNITEDSTATES == "No" &
        .data$INTERNATIONALPRIORITY == "No" &
        .data$ANCHORMARKET == "No"
      ) |>
      nrow()
  )
}

.getPriorityAssetStudyCount <- function(df) {
  return(
    df |>
      dplyr::filter(
        .data$DRUGPRIORITY == "Priority Asset"
      ) |>
      nrow()
  )
}

.getLaunchPriorityStudyCount <- function(df) {
  return(
    df |>
      dplyr::filter(
        .data$DRUGPRIORITY == "Launch Priority"
      ) |>
      nrow()
  )
}

.getTier1ResearchPriorityStudyCount <- function(df) {
  return(
    df |>
      dplyr::filter(
        .data$DRUGPRIORITY == "Tier 1 Research Priority"
      ) |>
      nrow()
  )
}

.getTier2ResearchPriorityStudyCount <- function(df) {
  return(
    df |>
      dplyr::filter(
        .data$DRUGPRIORITY == "Tier 2 Research Priority"
      ) |>
      nrow()
  )
}

.getOtherAssetStudyCount <- function(df) {
  return(
    df |>
      dplyr::filter(
        is.na(.data$DRUGPRIORITY)
      ) |>
      nrow()
  )
}

.getNoPfizerDrugStudyCount <- function(df) {
  return(
    df |>
      dplyr::filter(
        .data$DRUGPRIORITY == "No Drug"
      ) |>
      nrow()
  )
}
