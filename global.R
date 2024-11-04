config <- jsonlite::fromJSON(here::here("config", "default-config.json"),
                             simplifyDataFrame = FALSE)

# Not needed for current state of BoW app, but keeping consistent paradigm for future case
connection <- NULL
