
# ============================================================
# 01_data_collection.R
# COMP3020 Group 13 - Bluesky Data Collection
# ============================================================

library(atrrr)
library(dplyr)
library(purrr)
library(readr)

# Bluesky login
user <- Sys.getenv("BLUESKY_USER")
password <- Sys.getenv("BLUESKY_PASSWORD")

if (user == "" || password == "") {
  stop("Set BLUESKY_USER and BLUESKY_PASSWORD before running this script.")
}

auth(user = user, password = password)

# Search function
collect_topic <- function(topic, queries, limit = 300) {
  map_dfr(queries, function(q) {
    
    message("Collecting: ", topic, " | ", q)
    
    x <- search_post(q, limit = limit)
    
    if (nrow(x) == 0) return(tibble())
    
    x %>%
      mutate(
        topic = topic,
        search_term = q,
        collection_date = Sys.Date()
      )
  })
}

# Search terms
search_terms <- list(
  "AI-generated content" = c(
    "AI generated", "AI-generated", "generative AI",
    "AI art", "AI image", "AI video",
    "AI writing", "ChatGPT generated"
  ),
  "AI ethics" = c(
    "AI ethics", "ethical AI", "responsible AI",
    "AI bias", "AI privacy", "AI safety",
    "AI regulation", "AI fairness"
  )
)

# Collect data
raw_data <- map_dfr(
  names(search_terms),
  \(topic) collect_topic(
    topic,
    search_terms[[topic]]
  )
)

# Save data
dir.create(
  "data/raw",
  recursive = TRUE,
  showWarnings = FALSE
)

write_csv(
  raw_data,
  "data/raw/bluesky_raw.csv"
)

message("Collected ", nrow(raw_data), " raw posts.")
