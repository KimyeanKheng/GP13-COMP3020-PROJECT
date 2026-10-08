# COMP3020 Group 13
# 03_analysis.R
# Engagement statistics, term frequency and TF-IDF

library(tidyverse)
library(tidytext)

# Load cleaned data
dat <- read_csv("data/cleaned/final_dataset.csv", show_col_types = FALSE)

# Create total engagement
dat <- dat %>%
  mutate(
    topic = factor(topic, levels = c("AI-generated content", "AI ethics")),
    engagement_total = like_count + reply_count + repost_count
  )

# 1. DESCRIPTIVE STATISTICS
group_stats <- dat %>%
  group_by(topic) %>%
  summarise(
    n = n(),
    mean = mean(engagement_total, na.rm = TRUE),
    median = median(engagement_total, na.rm = TRUE),
    sd = sd(engagement_total, na.rm = TRUE),
    min = min(engagement_total, na.rm = TRUE),
    max = max(engagement_total, na.rm = TRUE),
    .groups = "drop"
  )
print(group_stats)
write_csv(group_stats, "data/cleaned/engagement_group_stats.csv")

# 2. WELCH TWO-SAMPLE T-TEST
welch <- t.test(engagement_total ~ topic, data = dat, var.equal = FALSE)
print(welch)

welch_results <- tibble(
  test = "Welch Two-Sample t-test",
  t_statistic = as.numeric(welch$statistic),
  degrees_freedom = as.numeric(welch$parameter),
  p_value = welch$p.value,
  confidence_low = welch$conf.int[1],
  confidence_high = welch$conf.int[2]
)
write_csv(welch_results, "data/cleaned/welch_test_results.csv")

# 3. COHEN'S d
pooled_sd <- sqrt(
  ((group_stats$n[1] - 1) * group_stats$sd[1]^2 +
     (group_stats$n[2] - 1) * group_stats$sd[2]^2) /
    (sum(group_stats$n) - 2)
)
cohens_d <- (group_stats$mean[1] - group_stats$mean[2]) / pooled_sd
cat("Cohen's d:", round(cohens_d, 3), "\n")
write_csv(tibble(measure = "Cohen's d", value = cohens_d),
          "data/cleaned/effect_size.csv")

# 4. MANN-WHITNEY U TEST
wilcox <- wilcox.test(engagement_total ~ topic, data = dat, exact = FALSE)
print(wilcox)

wilcox_results <- tibble(
  test = "Mann-Whitney U test",
  statistic = as.numeric(wilcox$statistic),
  p_value = wilcox$p.value
)
write_csv(wilcox_results, "data/cleaned/wilcox_test_results.csv")

# 5. TEXT PREPROCESSING
tokens <- dat %>%
  select(post_id, topic, text) %>%
  filter(!is.na(text), str_squish(text) != "") %>%
  mutate(
    text = str_replace_all(text, "https?\\S+|www\\.\\S+|t\\.co\\S+", " "),
    text = str_replace_all(text, "@[A-Za-z0-9_.]+", " "),
    text = str_replace_all(text, "[^A-Za-z\\s]", " ")
  ) %>%
  unnest_tokens(word, text) %>%
  anti_join(stop_words, by = "word") %>%
  filter(str_detect(word, "^[a-z]+$"), nchar(word) >= 3)

# 6. TERM FREQUENCY
term_frequency <- tokens %>%
  count(topic, word, sort = TRUE)
write_csv(term_frequency, "data/cleaned/term_frequency_results.csv")

top_terms <- term_frequency %>%
  group_by(topic) %>%
  slice_max(n, n = 10, with_ties = FALSE) %>%
  ungroup()
print(top_terms)

# 7. TF-IDF
tfidf <- term_frequency %>%
  bind_tf_idf(word, topic, n) %>%
  arrange(topic, desc(tf_idf))

top_tfidf <- tfidf %>%
  group_by(topic) %>%
  slice_max(tf_idf, n = 10, with_ties = FALSE) %>%
  ungroup()
print(top_tfidf)
write_csv(top_tfidf, "data/cleaned/top_tfidf_terms.csv")

cat("\n03_analysis.R completed successfully.\n")
