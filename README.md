# COMP3020 Group 13 – Social Web Analytics

## Project Overview

**Talking about AI, not to each other: How Bluesky discusses AI-generated content vs AI ethics**

This project analyses Bluesky social media data to investigate differences in user engagement between posts discussing AI-generated content and AI ethics. User engagement is measured using likes, replies, and reposts.

The project also explores differences in language, discussion themes, and user interaction patterns through statistical analysis, text mining, clustering, and network analysis.

## Research Question

**How does user engagement differ between Bluesky posts discussing AI-generated content and AI ethics?**

## Data

The data was collected from Bluesky using the `atrrr` package in R. A total of 16 search terms were used across two topic categories: AI-generated content and AI ethics.

According to the final project poster, the cleaned dataset contains **5,290 posts**, consisting of:

- **2,512 posts** about AI-generated content.
- **2,778 posts** about AI ethics.

The dataset includes engagement metrics such as likes, replies, and reposts, alongside post text and relevant metadata.

## Project Structure

- `01_data_collection.R` – Collects Bluesky posts using predefined search terms across the two research topics.
- `02_data_cleaning.R` – Removes duplicate and empty posts, preprocesses text, and standardises the collected data.
- `03_analysis.R` – Performs descriptive statistics, hypothesis testing, and text analysis, including word frequency and TF-IDF.
- `04_visualisation.R` – Generates visualisations of engagement patterns and textual differences between the two topics.
- `05_Clustering.R` – Applies TF-IDF and K-means clustering to explore discussion themes, supported by silhouette analysis and PCA visualisation.
- `06_network_analysis.R` – Constructs and analyses a directed user interaction network, including network structure and centrality measures.
- `GP13-COMP3020-PROJECT.git.Rproj` – RStudio project file.
- `README.md` – Project overview, methodology, and reproducibility information.

### Data Outputs

The data collection and cleaning scripts use the following output paths:

- `data/raw/bluesky_raw.csv` – Raw Bluesky dataset.
- `data/cleaned/final_dataset.csv` – Cleaned dataset prepared for subsequent analysis.

## Methodology

The project applies the following analytical methods:

1. **Data collection and preprocessing:** Collecting Bluesky posts, removing duplicates and empty records, and preparing text for analysis.
2. **Statistical analysis:** Comparing engagement between the two topics using Welch's t-test, Mann–Whitney U test, and Cohen's d.
3. **Text mining and visualisation:** Exploring word frequency and TF-IDF to identify differences in vocabulary and discussion themes.
4. **Clustering:** Applying K-means clustering to examine similarities and differences between discussions.
5. **Network analysis:** Examining reply and quote interactions to understand user connectivity within the sampled network.

## Key Findings

Based on the final project poster:

- Neither statistical test found a significant engagement difference at the 5% significance level.
- AI-generated content discussions focused more on creative tools and outputs, while AI ethics discussions focused more on responsibility, privacy, bias, and regulation.
- Clustering revealed differences in discussion themes, although overall cluster separation was weak.
- The sampled interaction network was sparse, with limited connectivity between users.

Overall, the findings suggest that the two topics differ more clearly in **what users discuss** than in **how much engagement their posts receive**.

## Reproducibility

This project uses R for data collection, cleaning, statistical analysis, text mining, visualisation, clustering, and network analysis.

Bluesky credentials should not be stored directly in the repository. The data collection script accesses credentials using the environment variables:

- `BLUESKY_USER`
- `BLUESKY_PASSWORD`

These credentials should be configured locally in a `.Renviron` file, which must be excluded from Git version control.

To reproduce the analysis:

1. Open the RStudio project.
2. Install the R packages required by the scripts.
3. Configure the Bluesky credentials locally.
4. Run `01_data_collection.R` to collect the data.
5. Run `02_data_cleaning.R` to prepare the dataset.
6. Run the remaining scripts in numerical order to reproduce the analyses and visualisations.

**Note:** Bluesky search results can change over time, so collecting new data may produce different sample sizes and results from those reported in the final project.

## Limitations

The dataset represents a sample of recent Bluesky posts collected through keyword searches. Engagement measures may be influenced by highly popular posts, while the network analysis only captures interactions available within the sampled data.

Therefore, the findings should not be generalised to all Bluesky users or the broader public.

## Group Members

COMP3020 Social Web Analytics – Group 13

- Gracelyn
- KimYean Kheng
- Thao Nhi Nguyen

## Repository

https://github.com/KimyeanKheng/GP13-COMP3020-PROJECT
