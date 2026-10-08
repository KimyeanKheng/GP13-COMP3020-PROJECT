library(tidyverse)
library(tidytext)
library(cluster)

set.seed(3020)

# Load data
dat <- read_csv(
  "data/cleaned/final_dataset.csv",
  show_col_types = FALSE
)

# 1. Text preprocessing
tokens <- dat %>%
  select(post_id, topic, text) %>%
  filter(!is.na(text), str_squish(text) != "") %>%
  mutate(
    text = str_replace_all(
      text,
      "https?\\S+|www\\.\\S+|t\\.co\\S+|@[A-Za-z0-9_.]+",
      " "
    ),
    text = str_replace_all(text, "[^A-Za-z\\s]", " ")
  ) %>%
  unnest_tokens(word, text) %>%
  anti_join(stop_words, by = "word") %>%
  filter(
    str_detect(word, "^[a-z]+$"),
    nchar(word) >= 3
  )

# 2. TF-IDF matrix
term_frequency <- tokens %>%
  count(post_id, word)

tfidf <- term_frequency %>%
  bind_tf_idf(word, post_id, n)

top_words <- tfidf %>%
  group_by(word) %>%
  summarise(total_frequency = sum(n), .groups = "drop") %>%
  slice_max(total_frequency, n = 500) %>%
  pull(word)

tfidf_matrix <- tfidf %>%
  filter(word %in% top_words) %>%
  select(post_id, word, tf_idf) %>%
  pivot_wider(
    names_from = word,
    values_from = tf_idf,
    values_fill = 0
  )

post_ids <- tfidf_matrix$post_id

tfidf_matrix <- tfidf_matrix %>%
  select(-post_id) %>%
  as.matrix()

keep_rows <- rowSums(tfidf_matrix) > 0

tfidf_matrix <- tfidf_matrix[
  keep_rows, , drop = FALSE
]

post_ids <- post_ids[keep_rows]

row_lengths <- sqrt(rowSums(tfidf_matrix^2))
tfidf_matrix <- tfidf_matrix / row_lengths

# 3. WSS
k_values <- 2:6
wss <- numeric(length(k_values))

for (i in seq_along(k_values)) {
  wss[i] <- kmeans(
    tfidf_matrix,
    centers = k_values[i],
    nstart = 10
  )$tot.withinss
}

wss_results <- tibble(
  k = k_values,
  wss = wss
)

print(wss_results)

write_csv(
  wss_results,
  "data/cleaned/clustering_wss.csv"
)

# 4. Silhouette scores
silhouette_results <- tibble(
  k = k_values,
  silhouette = NA_real_
)

for (i in seq_along(k_values)) {
  model <- kmeans(
    tfidf_matrix,
    centers = k_values[i],
    nstart = 10
  )
  
  sil <- silhouette(
    model$cluster,
    dist(tfidf_matrix)
  )
  
  silhouette_results$silhouette[i] <- mean(sil[, 3])
}

print(silhouette_results)

write_csv(
  silhouette_results,
  "data/cleaned/clustering_silhouette.csv"
)

# 5. Select best k
best_k <- silhouette_results$k[
  which.max(silhouette_results$silhouette)
]

cat("Selected number of clusters:", best_k, "\n")

# 6. Final k-means
final_kmeans <- kmeans(
  tfidf_matrix,
  centers = best_k,
  nstart = 25
)

cluster_results <- tibble(
  post_id = post_ids,
  cluster = final_kmeans$cluster
)

print(table(cluster_results$cluster))

write_csv(
  cluster_results,
  "data/cleaned/cluster_assignments.csv"
)

# 7. Cluster distribution by topic
cluster_topic <- cluster_results %>%
  left_join(
    select(dat, post_id, topic),
    by = "post_id"
  ) %>%
  count(cluster, topic)

print(cluster_topic)

write_csv(
  cluster_topic,
  "data/cleaned/cluster_topic_distribution.csv"
)

# 8. PCA
pca <- prcomp(
  tfidf_matrix,
  center = TRUE,
  scale. = FALSE
)

pca_data <- tibble(
  post_id = post_ids,
  PC1 = pca$x[, 1],
  PC2 = pca$x[, 2],
  cluster = factor(final_kmeans$cluster)
) %>%
  left_join(
    select(dat, post_id, topic),
    by = "post_id"
  )

dir.create(
  "figures",
  recursive = TRUE,
  showWarnings = FALSE
)

p_cluster <- ggplot(
  pca_data,
  aes(PC1, PC2, shape = cluster)
) +
  geom_point(alpha = 0.6) +
  labs(
    title = "Text-Based Clusters of Bluesky Posts",
    x = "Principal Component 1",
    y = "Principal Component 2",
    shape = "Cluster"
  ) +
  theme_minimal()

ggsave(
  "figures/05_cluster_visualisation.png",
  p_cluster,
  width = 8,
  height = 6,
  dpi = 300
)

cat("\n05_clustering.R completed successfully.\n")
