
# ============================================================
# 02_data_cleaning.R
# ============================================================

library(tidyverse)
library(tm)

raw_path <- "data/raw/bluesky_raw.csv"

if (!file.exists(raw_path)) {
  stop("Run data collection first.")
}

raw <- read_csv(
  raw_path,
  show_col_types = FALSE
)

# Find available columns
find_col <- function(df, x) {
  found <- x[x %in% names(df)]
  if (length(found) == 0) return(NULL)
  found[1]
}

author_col <- find_col(
  raw,
  c("author_handle", "author", "actor_handle")
)

date_col <- find_col(
  raw,
  c("indexed_at", "created_at")
)

like_col <- find_col(
  raw,
  c("like_count")
)

reply_col <- find_col(
  raw,
  c("reply_count")
)

repost_col <- find_col(
  raw,
  c("repost_count")
)

text_col <- find_col(
  raw,
  c("text")
)

lang_col <- find_col(
  raw,
  c("langs", "language", "lang")
)

id_col <- find_col(
  raw,
  c("uri", "post_id", "cid")
)

url_col <- find_col(
  raw,
  c("url", "uri", "post_url")
)

topic_col <- find_col(
  raw,
  c("topic")
)

# Check required fields
required <- list(
  author = author_col,
  date = date_col,
  likes = like_col,
  replies = reply_col,
  text = text_col,
  id = id_col,
  topic = topic_col,
  reposts = repost_col
)

missing <- names(required)[
  vapply(required, is.null, logical(1))
]

if (length(missing) > 0) {
  stop(
    paste(
      "Missing columns:",
      paste(missing, collapse = ", ")
    )
  )
}

# Clean text
clean_corpus <- function(x) {
  Corpus(VectorSource(x)) %>%
    tm_map(content_transformer(tolower)) %>%
    tm_map(removePunctuation) %>%
    tm_map(removeNumbers) %>%
    tm_map(stripWhitespace) %>%
    tm_map(removeWords, stopwords("english")) %>%
    tm_map(
      removeWords,
      c("https", "t.co", "www", "com", "amp", "rt")
    )
}

raw[[text_col]] <- sapply(
  clean_corpus(raw[[text_col]]),
  as.character
)

# Clean and standardise data
cleaned <- raw %>%
  filter(
    !is.na(.data[[id_col]]),
    !is.na(.data[[text_col]]),
    str_squish(.data[[text_col]]) != ""
  ) %>%
  distinct(
    .data[[id_col]],
    .keep_all = TRUE
  ) %>%
  filter(
    .data[[topic_col]] %in%
      c("AI-generated content", "AI ethics")
  ) %>%
  transmute(
    topic = as.character(.data[[topic_col]]),
    like_count = as.numeric(.data[[like_col]]),
    reply_count = as.numeric(.data[[reply_col]]),
    repost_count = as.numeric(.data[[repost_col]]),
    author = as.character(.data[[author_col]]),
    created_at = as.character(.data[[date_col]]),
    text = as.character(.data[[text_col]]),
    language = as.character(.data[[lang_col]]),
    post_id = as.character(.data[[id_col]]),
    url = as.character(.data[[url_col]])
  ) %>%
  filter(
    !is.na(post_id),
    !is.na(text),
    str_squish(text) != ""
  )

# Save cleaned data
dir.create(
  "data/cleaned",
  recursive = TRUE,
  showWarnings = FALSE
)

write_csv(
  cleaned,
  "data/cleaned/final_dataset.csv"
)

message("Final cleaned records: ", nrow(cleaned))
