# Script to generate publication-quality figures for the playstyle analysis
# This script should be run after the main analysis has been completed

library(tidyverse)
library(here)
library(ggpubr)
library(patchwork)
library(viridis)
library(scales)
library(factoextra)
library(interactions)

# Load the processed data
pvz_data <- readRDS(here("data/processed/pvz_with_clusters.rds"))

# Set theme for all plots
theme_set(
  theme_minimal(base_size = 12) +
    theme(
      text = element_text(family = "Times New Roman"),
      plot.title = element_text(size = 14, face = "bold"),
      plot.subtitle = element_text(size = 12),
      legend.position = "bottom",
      legend.title = element_text(face = "bold"),
      axis.title = element_text(face = "bold"),
      strip.text = element_text(face = "bold")
    )
)

# Color palettes
cluster_colors <- viridis_pal(option = "D")(5)
mode_colors <- c("PvP" = "#E74C3C", "PvE" = "#4E7FE3", "Social Hub" = "#2ECC71")

# Figure 1: Distribution of play time across game modes
fig1 <- pvz_data %>%
  select(player_id, pvp_hours, pve_hours, social_hours) %>%
  pivot_longer(
    cols = c(pvp_hours, pve_hours, social_hours),
    names_to = "mode",
    values_to = "hours"
  ) %>%
  mutate(
    mode = factor(
      mode,
      levels = c("pvp_hours", "pve_hours", "social_hours"),
      labels = c("PvP", "PvE", "Social Hub")
    )
  ) %>%
  ggplot(aes(x = hours, fill = mode)) +
  geom_histogram(
    binwidth = 2, 
    color = "white", 
    alpha = 0.8,
    position = "dodge"
  ) +
  labs(
    title = "Distribution of Play Time by Game Mode",
    x = "Hours (2-week period)",
    y = "Number of Players",
    fill = "Game Mode"
  ) +
  scale_fill_manual(values = mode_colors) +
  scale_x_continuous(breaks = pretty_breaks(n = 6)) +
  coord_cartesian(xlim = c(0, 40))  # Adjust as needed

# Save Figure 1
ggsave(
  here("figures/fig1_playtime_distribution.pdf"),
  fig1,
  width = 8,
  height = 6,
  dpi = 300
)

# Figure 2: Player clusters visualization
# Since the cluster data is multidimensional, we'll use PCA for visualization
fig2 <- fviz_cluster(
  list(data = scale(pvz_data %>% select(ratio_pvp_hours, ratio_pve_hours, pvp_kd, pve_kd)), 
       cluster = pvz_data$cluster),
  ellipse.type = "convex",
  repel = TRUE,
  labelsize = 8,
  palette = cluster_colors,
  ggtheme = theme_minimal(),
  main = "Player Type Clusters",
  xlab = "Principal Component 1",
  ylab = "Principal Component 2"
) +
  theme(
    text = element_text(family = "Times New Roman"),
    plot.title = element_text(size = 14, face = "bold"),
    legend.position = "bottom",
    legend.title = element_text(face = "bold")
  )

# Save Figure 2
ggsave(
  here("figures/fig2_player_clusters.pdf"),
  fig2,
  width = 8,
  height = 7,
  dpi = 300
)

# Figure 3: Cluster profiles (radar chart)
# Calculate cluster means for key metrics
cluster_profiles <- pvz_data %>%
  group_by(player_type) %>%
  summarise(
    n = n(),
    pvp_ratio = mean(ratio_pvp_hours, na.rm = TRUE),
    pve_ratio = mean(ratio_pve_hours, na.rm = TRUE),
    hours = mean(hours, na.rm = TRUE),
    pvp_kd = mean(pvp_kd, na.rm = TRUE),
    pvp_accuracy = mean(pvp_hit_accuracy, na.rm = TRUE),
    pve_kd = mean(pve_kd, na.rm = TRUE),
    pve_accuracy = mean(pve_hit_accuracy, na.rm = TRUE)
  )

# Create a table for the cluster profiles
cluster_table <- cluster_profiles %>%
  select(-n) %>%
  mutate(across(where(is.numeric), ~ round(., 2)))

# Save the table
write.csv(cluster_table, here("figures/cluster_profiles.csv"), row.names = FALSE)

# Figure 4: Playtime vs. Well-being by player type
# Need to center hours for better visualization
pvz_data <- pvz_data %>%
  mutate(hours_c = hours - mean(hours, na.rm = TRUE))

# Fit model
wellbeing_model <- lm(spane_game_balance ~ hours_c * player_type, data = pvz_data)

# Plot interaction
fig4 <- interact_plot(
  wellbeing_model,
  pred = "hours_c",
  modx = "player_type",
  plot.points = TRUE,
  point.alpha = 0.3,
  colors = cluster_colors,
  x.label = "Hours Played (centered)",
  y.label = "Game-Related Well-Being",
  legend.main = "Player Type"
) +
  theme(
    text = element_text(family = "Times New Roman"),
    plot.title = element_text(size = 14, face = "bold"),
    legend.position = "bottom"
  ) +
  labs(title = "Relationship Between Play Time and Well-Being by Player Type")

# Save Figure 4
ggsave(
  here("figures/fig4_wellbeing_by_player_type.pdf"),
  fig4,
  width = 8,
  height = 6,
  dpi = 300
)

# Figure 5: Game mode distribution by player type
fig5 <- pvz_data %>%
  select(player_type, pvp_hours, pve_hours, social_hours) %>%
  group_by(player_type) %>%
  summarise(
    PvP = mean(pvp_hours, na.rm = TRUE),
    PvE = mean(pve_hours, na.rm = TRUE),
    `Social Hub` = mean(social_hours, na.rm = TRUE)
  ) %>%
  pivot_longer(
    cols = c(PvP, PvE, `Social Hub`),
    names_to = "mode",
    values_to = "hours"
  ) %>%
  ggplot(aes(x = player_type, y = hours, fill = mode)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(
    title = "Average Play Time by Game Mode and Player Type",
    x = "Player Type",
    y = "Average Hours (2-week period)",
    fill = "Game Mode"
  ) +
  scale_fill_manual(values = mode_colors) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1)
  )

# Save Figure 5
ggsave(
  here("figures/fig5_game_mode_by_player_type.pdf"),
  fig5,
  width = 9,
  height = 6,
  dpi = 300
)

# Figure 6: Motivation variables by player type
fig6 <- pvz_data %>%
  select(player_type, enjoyment, competence, autonomy, relatedness, extrinsic) %>%
  pivot_longer(
    cols = c(enjoyment, competence, autonomy, relatedness, extrinsic),
    names_to = "motivation",
    values_to = "score"
  ) %>%
  mutate(
    motivation = str_to_title(motivation),
    motivation = factor(
      motivation,
      levels = c("Enjoyment", "Competence", "Autonomy", "Relatedness", "Extrinsic")
    )
  ) %>%
  ggplot(aes(x = motivation, y = score, fill = player_type)) +
  geom_boxplot(alpha = 0.7) +
  labs(
    title = "Motivation Variables by Player Type",
    x = NULL,
    y = "Score",
    fill = "Player Type"
  ) +
  scale_fill_manual(values = cluster_colors) +
  theme(
    axis.text.x = element_text(angle = 0)
  )

# Save Figure 6
ggsave(
  here("figures/fig6_motivation_by_player_type.pdf"),
  fig6,
  width = 10,
  height = 6,
  dpi = 300
)

# Combine figures into a summary figure for the paper
# This creates a 2x2 layout of key figures
summary_fig <- (fig1 + fig2) / (fig4 + fig5) +
  plot_annotation(
    title = "Player Types, Game Mode Preferences, and Well-Being",
    subtitle = "Analysis of Plants vs. Zombies: Battle for Neighborville player data",
    theme = theme(
      plot.title = element_text(size = 16, face = "bold"),
      plot.subtitle = element_text(size = 12)
    )
  )

# Save the summary figure
ggsave(
  here("figures/summary_figure.pdf"),
  summary_fig,
  width = 12,
  height = 10,
  dpi = 300
)

# Print confirmation
cat("All figures have been saved to the 'figures' directory.\n") 