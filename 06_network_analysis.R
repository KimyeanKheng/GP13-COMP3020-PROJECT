library(tidyverse)
library(igraph)

# Load raw data
raw <- read_csv(
  "data/raw/bluesky_raw.csv",
  show_col_types = FALSE
)

# 1. Reply and quote relationships
reply_edges <- raw %>%
  filter(!is.na(in_reply_to), in_reply_to != "") %>%
  transmute(
    source_uri = uri,
    target_uri = in_reply_to,
    interaction_type = "reply"
  )

quote_edges <- raw %>%
  filter(!is.na(quotes), quotes != "") %>%
  transmute(
    source_uri = uri,
    target_uri = quotes,
    interaction_type = "quote"
  )

interaction_edges <- bind_rows(
  reply_edges,
  quote_edges
)

cat("Reply relationships:", nrow(reply_edges), "\n")
cat("Quote relationships:", nrow(quote_edges), "\n")

# 2. Match posts to users
post_authors <- raw %>%
  select(
    target_uri = uri,
    target_author = author_handle
  ) %>%
  distinct()

source_authors <- raw %>%
  select(
    source_uri = uri,
    source_author = author_handle
  ) %>%
  distinct()

network_edges <- interaction_edges %>%
  left_join(source_authors, by = "source_uri") %>%
  left_join(post_authors, by = "target_uri") %>%
  filter(
    !is.na(source_author),
    !is.na(target_author),
    source_author != target_author
  )

# 3. Count interactions
network_edges_summary <- network_edges %>%
  count(
    source_author,
    target_author,
    name = "weight"
  )

write_csv(
  network_edges_summary,
  "data/cleaned/network_edges.csv"
)

# 4. Create network
network_graph <- graph_from_data_frame(
  network_edges_summary,
  directed = TRUE
)

# 5. Network summary
network_components <- components(
  network_graph,
  mode = "weak"
)

network_summary <- tibble(
  nodes = vcount(network_graph),
  edges = ecount(network_graph),
  density = edge_density(network_graph),
  components = network_components$no,
  largest_component = max(network_components$csize)
)

print(network_summary)

write_csv(
  network_summary,
  "data/cleaned/network_summary.csv"
)

# 6. Centrality
degree_in <- degree(
  network_graph,
  mode = "in"
)

degree_out <- degree(
  network_graph,
  mode = "out"
)

betweenness_score <- betweenness(
  network_graph,
  directed = TRUE,
  normalized = TRUE
)

centrality_data <- tibble(
  user = names(degree_in),
  degree_in = as.numeric(degree_in),
  degree_out = as.numeric(degree_out),
  betweenness = as.numeric(betweenness_score)
)

# 7. Top users by in-degree
top_indegree <- centrality_data %>%
  arrange(desc(degree_in)) %>%
  slice_head(n = 10)

print(top_indegree)

write_csv(
  top_indegree,
  "data/cleaned/top_indegree_users.csv"
)

# 8. Top users by betweenness
top_betweenness <- centrality_data %>%
  arrange(desc(betweenness)) %>%
  slice_head(n = 10)

print(top_betweenness)

write_csv(
  top_betweenness,
  "data/cleaned/top_betweenness_users.csv"
)

# 9. Network visualisation
dir.create(
  "figures",
  recursive = TRUE,
  showWarnings = FALSE
)

set.seed(3020)

png(
  "figures/06_network.png",
  width = 1800,
  height = 1400,
  res = 200
)

plot(
  network_graph,
  vertex.size = 6,
  vertex.label = NA,
  edge.arrow.size = 0.2,
  main = "Bluesky Interaction Network"
)

dev.off()

cat("\n06_network_analysis.R completed successfully.\n")