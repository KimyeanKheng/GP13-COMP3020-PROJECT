# COMP3020 Group 13
# 04_visualisation.R
# Engagement plots, top terms and word clouds
# Run after 03_analysis.R (needs data/cleaned/term_frequency_results.csv)

library(tidyverse)
library(wordcloud)

topic_colours <- c(
  "AI-generated content" = "steelblue",
  "AI ethics" = "orange"
)

dat <- read_csv("data/cleaned/final_dataset.csv", show_col_types = FALSE) %>%
  mutate(
    topic = factor(topic),
    engagement_total = like_count + reply_count + repost_count
  )

dir.create("figures", showWarnings = FALSE)

# 1. Engagement distribution
p1 <- ggplot(dat, aes(engagement_total, fill = topic)) +
  geom_histogram(bins = 40) +
  facet_wrap(~topic, scales = "free") +
  scale_fill_manual(values = topic_colours) +
  labs(title = "Distribution of Total Engagement by Topic",
       x = "Total Engagement", y = "Number of Posts") +
  theme_minimal() +
  theme(legend.position = "none")
print(p1)
ggsave("figures/01_engagement_distribution.png", p1, width = 9, height = 5, dpi = 300)

# 2. Log engagement boxplot
p2 <- ggplot(dat, aes(topic, log1p(engagement_total), fill = topic)) +
  geom_boxplot() +
  scale_fill_manual(values = topic_colours) +
  labs(title = "Log-Transformed Total Engagement by Topic",
       x = NULL, y = "log(1 + Engagement)") +
  theme_minimal() +
  theme(legend.position = "none")
print(p2)
ggsave("figures/02_log_engagement_boxplot.png", p2, width = 8, height = 5, dpi = 300)

# 3. Mean engagement with 95% CI
mean_data <- dat %>%
  group_by(topic) %>%
  summarise(
    mean = mean(engagement_total),
    se = sd(engagement_total) / sqrt(n()),
    lower = mean - 1.96 * se,
    upper = mean + 1.96 * se
  )

p3 <- ggplot(mean_data, aes(topic, mean, fill = topic)) +
  geom_col(width = 0.6) +
  geom_errorbar(aes(ymin = lower, ymax = upper), width = 0.15) +
  scale_fill_manual(values = topic_colours) +
  labs(title = "Mean Total Engagement with 95% Confidence Intervals",
       x = NULL, y = "Mean Total Engagement") +
  theme_minimal() +
  theme(legend.position = "none")
print(p3)
ggsave("figures/03_mean_engagement_ci.png", p3, width = 8, height = 5, dpi = 300)

# 4. Most frequent terms
top_terms <- read_csv("data/cleaned/term_frequency_results.csv", show_col_types = FALSE) %>%
  group_by(topic) %>%
  slice_max(n, n = 10, with_ties = FALSE) %>%
  ungroup()

p4 <- ggplot(top_terms, aes(reorder(word, n), n, fill = topic)) +
  geom_col() +
  coord_flip() +
  facet_wrap(~topic, scales = "free") +
  scale_fill_manual(values = topic_colours) +
  labs(title = "Most Frequent Terms by Topic", x = NULL, y = "Frequency") +
  theme_minimal() +
  theme(legend.position = "none")
print(p4)
ggsave("figures/04_top_terms.png", p4, width = 9, height = 6, dpi = 300)

# 5. Word clouds
wordcloud_data <- read_csv("data/cleaned/term_frequency_results.csv", show_col_types = FALSE)

ai_generated <- wordcloud_data %>%
  filter(topic == "AI-generated content") %>%
  slice_max(n, n = 50)

ai_ethics <- wordcloud_data %>%
  filter(topic == "AI ethics") %>%
  slice_max(n, n = 50)

png("figures/05_wordclouds.png", 2400, 1200, res = 200)
par(mfrow = c(1, 2), mar = c(1, 1, 3, 1))

wordcloud(ai_generated$word, ai_generated$n, max.words = 50,
          random.order = FALSE, rot.per = 0.1, scale = c(4, 0.8))
title("AI-Generated Content")

wordcloud(ai_ethics$word, ai_ethics$n, max.words = 50,
          random.order = FALSE, rot.per = 0.1, scale = c(4, 0.8))
title("AI Ethics")

dev.off()

cat("\n04_visualisation.R completed successfully.\n")
