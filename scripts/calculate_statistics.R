# Script to calculate and summarize key statistics for the playstyle analysis

library(tidyverse)
library(here)
library(sjPlot)
library(broom)
library(lme4)
library(sjstats)
library(car)
library(knitr)

# Load the processed data
pvz_data <- readRDS(here("data/processed/pvz_with_clusters.rds"))

# Create a directory for statistics output
dir.create(here("statistics"), showWarnings = FALSE)

# 1. Descriptive Statistics ---------------------------------------------------

# Demographics
demographics <- pvz_data %>%
  summarise(
    n_participants = n(),
    mean_age = mean(age, na.rm = TRUE),
    sd_age = sd(age, na.rm = TRUE),
    median_age = median(age, na.rm = TRUE),
    n_male = sum(gender == "Male", na.rm = TRUE),
    pct_male = mean(gender == "Male", na.rm = TRUE) * 100,
    n_female = sum(gender == "Female", na.rm = TRUE),
    pct_female = mean(gender == "Female", na.rm = TRUE) * 100,
    n_other = sum(gender == "Other", na.rm = TRUE),
    pct_other = mean(gender == "Other", na.rm = TRUE) * 100,
    n_prefer_not_to_say = sum(gender == "Prefer not to say", na.rm = TRUE),
    pct_prefer_not_to_say = mean(gender == "Prefer not to say", na.rm = TRUE) * 100
  )

# Game time statistics
gametime_stats <- pvz_data %>%
  summarise(
    mean_hours = mean(hours, na.rm = TRUE),
    sd_hours = sd(hours, na.rm = TRUE),
    median_hours = median(hours, na.rm = TRUE),
    min_hours = min(hours, na.rm = TRUE),
    max_hours = max(hours, na.rm = TRUE),
    mean_pvp_hours = mean(pvp_hours, na.rm = TRUE),
    sd_pvp_hours = sd(pvp_hours, na.rm = TRUE),
    mean_pve_hours = mean(pve_hours, na.rm = TRUE),
    sd_pve_hours = sd(pve_hours, na.rm = TRUE),
    mean_social_hours = mean(social_hours, na.rm = TRUE),
    sd_social_hours = sd(social_hours, na.rm = TRUE)
  )

# Well-being and motivation statistics
wellbeing_stats <- pvz_data %>%
  summarise(
    mean_spane_balance = mean(spane_balance, na.rm = TRUE),
    sd_spane_balance = sd(spane_balance, na.rm = TRUE),
    mean_spane_game_balance = mean(spane_game_balance, na.rm = TRUE),
    sd_spane_game_balance = sd(spane_game_balance, na.rm = TRUE),
    mean_autonomy = mean(autonomy, na.rm = TRUE),
    sd_autonomy = sd(autonomy, na.rm = TRUE),
    mean_competence = mean(competence, na.rm = TRUE),
    sd_competence = sd(competence, na.rm = TRUE),
    mean_relatedness = mean(relatedness, na.rm = TRUE),
    sd_relatedness = sd(relatedness, na.rm = TRUE),
    mean_enjoyment = mean(enjoyment, na.rm = TRUE),
    sd_enjoyment = sd(enjoyment, na.rm = TRUE),
    mean_extrinsic = mean(extrinsic, na.rm = TRUE),
    sd_extrinsic = sd(extrinsic, na.rm = TRUE)
  )

# Performance metrics by player type
performance_by_type <- pvz_data %>%
  group_by(player_type) %>%
  summarise(
    n = n(),
    mean_hours = mean(hours, na.rm = TRUE),
    sd_hours = sd(hours, na.rm = TRUE),
    mean_pvp_ratio = mean(ratio_pvp_hours, na.rm = TRUE),
    sd_pvp_ratio = sd(ratio_pvp_hours, na.rm = TRUE),
    mean_pve_ratio = mean(ratio_pve_hours, na.rm = TRUE),
    sd_pve_ratio = sd(ratio_pve_hours, na.rm = TRUE),
    mean_pvp_kd = mean(pvp_kd, na.rm = TRUE),
    sd_pvp_kd = sd(pvp_kd, na.rm = TRUE),
    mean_pve_kd = mean(pve_kd, na.rm = TRUE),
    sd_pve_kd = sd(pve_kd, na.rm = TRUE),
    mean_pvp_hit_accuracy = mean(pvp_hit_accuracy, na.rm = TRUE),
    sd_pvp_hit_accuracy = sd(pvp_hit_accuracy, na.rm = TRUE),
    mean_pve_hit_accuracy = mean(pve_hit_accuracy, na.rm = TRUE),
    sd_pve_hit_accuracy = sd(pve_hit_accuracy, na.rm = TRUE),
    mean_pvp_dps = mean(pvp_dps, na.rm = TRUE),
    sd_pvp_dps = sd(pvp_dps, na.rm = TRUE),
    mean_pve_dps = mean(pve_dps, na.rm = TRUE),
    sd_pve_dps = sd(pve_dps, na.rm = TRUE)
  )

# Write descriptive statistics to files
write.csv(demographics, here("statistics/demographics.csv"), row.names = FALSE)
write.csv(gametime_stats, here("statistics/gametime_stats.csv"), row.names = FALSE)
write.csv(wellbeing_stats, here("statistics/wellbeing_stats.csv"), row.names = FALSE)
write.csv(performance_by_type, here("statistics/performance_by_type.csv"), row.names = FALSE)

# 2. Cluster Analysis Statistics ---------------------------------------------

# Get silhouette score for clustering
cluster_data <- pvz_data %>% 
  select(
    ratio_pvp_hours, ratio_pve_hours,
    pvp_kd, pvp_hit_accuracy, pvp_dps,
    pve_kd, pve_hit_accuracy, pve_dps
  )
cluster_data_scaled <- scale(cluster_data)
set.seed(123)
km_res <- kmeans(cluster_data_scaled, centers = 5, nstart = 25)

# Calculate silhouette score
library(cluster)
sil <- silhouette(km_res$cluster, dist(cluster_data_scaled))
sil_summary <- summary(sil)

# ANOVA to test differences between clusters on key metrics
cluster_anova_results <- list()

# Function to run ANOVA and extract results
run_anova <- function(dv) {
  formula <- as.formula(paste(dv, "~ player_type"))
  model <- aov(formula, data = pvz_data)
  result <- broom::tidy(model)
  result$eta_squared <- sjstats::eta_sq(model)[["eta.sq"]]
  result$variable <- dv
  return(result)
}

# Run ANOVAs for key variables
variables <- c("hours", "ratio_pvp_hours", "ratio_pve_hours", 
               "pvp_kd", "pve_kd", "pvp_hit_accuracy", "pve_hit_accuracy",
               "spane_game_balance", "enjoyment", "competence", 
               "autonomy", "relatedness")

for (var in variables) {
  cluster_anova_results[[var]] <- run_anova(var)
}

# Combine results
cluster_anova_df <- bind_rows(cluster_anova_results)

# Write cluster statistics to files
write.csv(as.data.frame(sil_summary), here("statistics/silhouette_summary.csv"), row.names = FALSE)
write.csv(cluster_anova_df, here("statistics/cluster_anova_results.csv"), row.names = FALSE)

# 3. Regression Models -------------------------------------------------------

# Center hours for interpretability
pvz_data <- pvz_data %>%
  mutate(hours_c = hours - mean(hours, na.rm = TRUE))

# Base model: Wellbeing ~ Hours
wellbeing_model_0 <- lm(spane_game_balance ~ hours_c, data = pvz_data)

# Model with player type as main effect
wellbeing_model_1 <- lm(spane_game_balance ~ hours_c + player_type, data = pvz_data)

# Model with player type interaction
wellbeing_model_2 <- lm(spane_game_balance ~ hours_c * player_type, data = pvz_data)

# Mixed-effects models
mixed_model_1 <- lmer(spane_game_balance ~ hours_c + (1 | player_type), data = pvz_data)
mixed_model_2 <- lmer(spane_game_balance ~ hours_c + (1 + hours_c | player_type), data = pvz_data)

# Create model summaries
model_summary_0 <- summary(wellbeing_model_0)
model_summary_1 <- summary(wellbeing_model_1)
model_summary_2 <- summary(wellbeing_model_2)
mixed_summary_1 <- summary(mixed_model_1)
mixed_summary_2 <- summary(mixed_model_2)

# Model comparisons
anova_linear <- anova(wellbeing_model_0, wellbeing_model_1, wellbeing_model_2)
anova_mixed <- anova(mixed_model_1, mixed_model_2)

# Create a formatted HTML table comparing all models
tab_model(
  wellbeing_model_0, 
  wellbeing_model_1, 
  wellbeing_model_2,
  mixed_model_1,
  mixed_model_2,
  file = here("statistics/model_comparison.html")
)

# Export model summaries
capture.output(model_summary_0, file = here("statistics/model_summary_0.txt"))
capture.output(model_summary_1, file = here("statistics/model_summary_1.txt"))
capture.output(model_summary_2, file = here("statistics/model_summary_2.txt"))
capture.output(mixed_summary_1, file = here("statistics/mixed_summary_1.txt"))
capture.output(mixed_summary_2, file = here("statistics/mixed_summary_2.txt"))
capture.output(anova_linear, file = here("statistics/anova_linear.txt"))
capture.output(anova_mixed, file = here("statistics/anova_mixed.txt"))

# 4. Effect Sizes and Confidence Intervals ----------------------------------

# Calculate standardized coefficients for main model
std_model <- lm(scale(spane_game_balance) ~ scale(hours_c) * player_type, data = pvz_data)
std_coeffs <- coef(summary(std_model))

# Calculate confidence intervals
ci_model_0 <- confint(wellbeing_model_0)
ci_model_2 <- confint(wellbeing_model_2)

# Write effect size information to files
write.csv(std_coeffs, here("statistics/standardized_coefficients.csv"))
write.csv(ci_model_0, here("statistics/confidence_intervals_model_0.csv"))
write.csv(ci_model_2, here("statistics/confidence_intervals_model_2.csv"))

# 5. Create a Summary Table for Paper ----------------------------------------

# Correlation matrix between key variables
cor_matrix <- cor(
  pvz_data %>% 
    select(hours, spane_game_balance, autonomy, competence, 
           relatedness, enjoyment, extrinsic),
  use = "pairwise.complete.obs"
)

# Write correlation matrix
write.csv(cor_matrix, here("statistics/correlation_matrix.csv"))

# Create a summary of key findings
key_findings <- data.frame(
  Finding = c(
    "Number of participants",
    "Player types identified",
    "Overall relationship between play time and well-being",
    "Relationship moderated by player type",
    "Strongest positive relationship for player type",
    "Weakest relationship for player type",
    "Mixed model comparison p-value",
    "R² for base model (playtime only)",
    "R² for interaction model (playtime × player type)"
  ),
  Value = c(
    nrow(pvz_data),
    "5 distinct clusters",
    paste("β =", round(coef(wellbeing_model_0)[2], 3), 
          "(p =", round(summary(wellbeing_model_0)$coefficients[2, 4], 3), ")"),
    paste("F(", anova_linear$Df[3], ",", anova_linear$Res.Df[3], ") =", 
          round(anova_linear$F[2], 2), ", p =", round(anova_linear$`Pr(>F)`[2], 3)),
    names(which.max(coef(wellbeing_model_2)[grep("hours_c:", names(coef(wellbeing_model_2)))])),
    names(which.min(coef(wellbeing_model_2)[grep("hours_c:", names(coef(wellbeing_model_2)))])),
    round(anova_mixed$`Pr(>Chisq)`[2], 3),
    round(summary(wellbeing_model_0)$r.squared, 3),
    round(summary(wellbeing_model_2)$r.squared, 3)
  )
)

# Write key findings
write.csv(key_findings, here("statistics/key_findings.csv"), row.names = FALSE)

# Print confirmation
cat("All statistics have been calculated and saved to the 'statistics' directory.\n") 