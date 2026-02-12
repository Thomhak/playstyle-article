# helpers.R
# Helper functions for playstyle manuscript analysis
# These functions support reproducible analysis and reporting

# ============================================
# Formatting Functions
# ============================================

#' Format p-value for inline reporting
#' @param p numeric p-value
#' @param digits number of decimal places
#' @return formatted string
format_pvalue <- function(p, digits = 3) {
  if (p < 0.001) {
    return("< .001")
  } else {
    return(sprintf(paste0("= %.", digits, "f"), p))
  }
}

#' Format estimate with confidence interval
#' @param estimate numeric estimate
#' @param ci_low lower CI bound
#' @param ci_high upper CI bound
#' @param digits number of decimal places
#' @return formatted string
format_estimate_ci <- function(estimate, ci_low, ci_high, digits = 2) {
  sprintf(
    "%.*f [%.*f, %.*f]",
    digits,
    estimate,
    digits,
    ci_low,
    digits,
    ci_high
  )
}

#' Format model coefficient for inline reporting
#' @param model fitted model object
#' @param term character name of coefficient
#' @param digits number of decimal places
#' @return formatted string with b, SE, t
format_coefficient <- function(model, term, digits = 2) {
  coefs <- coef(summary(model))
  if (!term %in% rownames(coefs)) {
    return("(term not found)")
  }
  b <- coefs[term, "Estimate"]
  se <- coefs[term, "Std. Error"]
  t_val <- coefs[term, "t value"]
  sprintf("b = %.*f, SE = %.*f, t = %.*f", digits, b, digits, se, digits, t_val)
}

# ============================================
# Model Caching Functions
# ============================================

#' Save model to disk with metadata
#' @param model fitted model object
#' @param name character model name
#' @param path character directory path
save_model <- function(model, name, path = "output/models") {
  if (!dir.exists(path)) {
    dir.create(path, recursive = TRUE)
  }
  filepath <- file.path(path, paste0(name, ".rds"))
  saveRDS(model, filepath)
  message(sprintf("Model saved to %s", filepath))
  invisible(filepath)
}

#' Load model from disk if exists
#' @param name character model name
#' @param path character directory path
#' @return model object or NULL if not found
load_model <- function(name, path = "output/models") {
  filepath <- file.path(path, paste0(name, ".rds"))
  if (file.exists(filepath)) {
    return(readRDS(filepath))
  }
  return(NULL)
}

#' Check if cached model exists
#' @param name character model name
#' @param path character directory path
#' @return logical
model_exists <- function(name, path = "output/models") {
  filepath <- file.path(path, paste0(name, ".rds"))
  file.exists(filepath)
}

# ============================================
# Statistical Helper Functions
# ============================================

#' Manual Hopkins statistic calculation for cluster tendency
#' @param data matrix or data frame (should be scaled)
#' @param m number of sampling points (default: 30, ~7% of typical dataset)
#' @return Hopkins statistic value
manual_hopkins <- function(data, m = 30) {
  n <- nrow(data)
  d <- ncol(data)

  # Sample m points from the data
  sample_indices <- sample(n, m)
  sample_points <- data[sample_indices, , drop = FALSE]

  # Generate m random points within the data space
  min_vals <- apply(data, 2, min)
  max_vals <- apply(data, 2, max)

  random_points <- matrix(NA, nrow = m, ncol = d)
  for (i in 1:d) {
    random_points[, i] <- runif(m, min_vals[i], max_vals[i])
  }

  # Calculate distances
  # For sample points: find nearest neighbor in original data
  sample_distances <- numeric(m)
  for (i in 1:m) {
    distances_to_others <- sqrt(rowSums(
      (data[-sample_indices[i], , drop = FALSE] -
        matrix(sample_points[i, ], nrow = n - 1, ncol = d, byrow = TRUE))^2
    ))
    sample_distances[i] <- min(distances_to_others)
  }

  # For random points: find nearest neighbor in original data
  random_distances <- numeric(m)
  for (i in 1:m) {
    distances_to_data <- sqrt(rowSums(
      (data -
        matrix(random_points[i, ], nrow = n, ncol = d, byrow = TRUE))^2
    ))
    random_distances[i] <- min(distances_to_data)
  }

  # Hopkins statistic
  U <- sum(sample_distances)
  W <- sum(random_distances)
  H <- W / (U + W)

  return(H)
}

#' Compute Hopkins statistic for cluster tendency with confidence interval
#' @param data matrix or data frame (should be scaled)
#' @param m number of sampling points (default: 30)
#' @param iter number of iterations for confidence interval (default: 10)
#' @return list with mean Hopkins statistic and confidence interval
compute_hopkins_statistic <- function(data, m = 30, iter = 10) {
  hopkins_values <- numeric(iter)
  for (i in 1:iter) {
    set.seed(123 + i)
    hopkins_values[i] <- manual_hopkins(data, m = m)
  }

  mean_hopkins <- mean(hopkins_values)
  sd_hopkins <- sd(hopkins_values)
  ci_lower <- mean_hopkins - 1.96 * sd_hopkins
  ci_upper <- mean_hopkins + 1.96 * sd_hopkins

  return(list(
    hopkins = mean_hopkins,
    sd = sd_hopkins,
    ci_lower = ci_lower,
    ci_upper = ci_upper,
    values = hopkins_values
  ))
}

#' Calculate simple slopes for moderation analysis
#' @param model fitted robust mixed model (rlmerMod)
#' @param moderator character name of moderator variable
#' @param predictor character name of predictor variable
#' @param data data frame used for fitting
#' @return data frame with slope estimates and tests
calculate_simple_slopes <- function(
  model,
  moderator = "player_type",
  predictor = "hours",
  data
) {
  coefs <- lme4::fixef(model)
  vcov_matrix <- vcov(model)

  # Get moderator levels
  mod_levels <- levels(data[[moderator]])

  # Base effect (reference level)
  predictor_effect <- coefs[predictor]
  predictor_se <- sqrt(vcov_matrix[predictor, predictor])

  results <- data.frame(
    level = mod_levels[1],
    estimate = predictor_effect,
    std.error = predictor_se,
    statistic = predictor_effect / predictor_se,
    stringsAsFactors = FALSE
  )
  results$p.value <- 2 *
    pt(
      abs(results$statistic),
      df = nrow(data) - length(coefs),
      lower.tail = FALSE
    )

  # Calculate for other levels

  for (i in 2:length(mod_levels)) {
    lev <- mod_levels[i]
    interaction_term <- paste0(moderator, lev, ":", predictor)

    if (interaction_term %in% names(coefs)) {
      slope <- predictor_effect + coefs[interaction_term]
      var_pred <- vcov_matrix[predictor, predictor]
      var_inter <- vcov_matrix[interaction_term, interaction_term]
      cov_pred_inter <- vcov_matrix[predictor, interaction_term]
      slope_se <- sqrt(var_pred + var_inter + 2 * cov_pred_inter)

      t_stat <- slope / slope_se
      p_val <- 2 *
        pt(abs(t_stat), df = nrow(data) - length(coefs), lower.tail = FALSE)

      results <- rbind(
        results,
        data.frame(
          level = lev,
          estimate = slope,
          std.error = slope_se,
          statistic = t_stat,
          p.value = p_val,
          stringsAsFactors = FALSE
        )
      )
    }
  }

  # Add CI and significance markers
  results <- results |>
    dplyr::mutate(
      conf.low = estimate - 1.96 * std.error,
      conf.high = estimate + 1.96 * std.error,
      significant = p.value < 0.05,
      stars = dplyr::case_when(
        p.value < 0.001 ~ "***",
        p.value < 0.01 ~ "**",
        p.value < 0.05 ~ "*",
        p.value < 0.1 ~ "†",
        TRUE ~ ""
      )
    )

  return(results)
}

# ============================================
# Table Formatting Functions
# ============================================

#' Add continuous variable row to demographics table
#' @param data data frame
#' @param var character variable name
#' @param label character display label
#' @param digits integer decimal places
#' @return tibble with formatted row
add_continuous_row <- function(data, var, label, digits = 1) {
  m <- mean(data[[var]], na.rm = TRUE)
  s <- sd(data[[var]], na.rm = TRUE)
  tibble::tibble(
    Characteristic = label,
    Total = sprintf("%.*f (%.*f)", digits, m, digits, s)
  )
}

#' Add categorical variable rows to demographics table
#' @param data data frame
#' @param var character variable name
#' @param levels_order optional character vector for level ordering
#' @return tibble with formatted rows
add_categorical_rows <- function(data, var, levels_order = NULL) {
  counts <- data |>
    dplyr::count(.data[[var]]) |>
    dplyr::mutate(pct = n / sum(n) * 100)

  if (!is.null(levels_order)) {
    counts <- counts |>
      dplyr::mutate(!!var := factor(.data[[var]], levels = levels_order)) |>
      dplyr::arrange(.data[[var]])
  }

  tibble::tibble(
    Characteristic = paste0("    ", counts[[var]]),
    Total = sprintf("%d (%.1f%%)", counts$n, counts$pct)
  )
}

#' Add median/IQR row for skewed variables
#' @param data data frame
#' @param var character variable name
#' @param label character display label
#' @param digits integer decimal places
#' @return tibble with formatted row
add_median_iqr_row <- function(data, var, label, digits = 1) {
  med <- median(data[[var]], na.rm = TRUE)
  iqr <- IQR(data[[var]], na.rm = TRUE)
  tibble::tibble(
    Characteristic = label,
    Total = sprintf("%.*f (%.*f)", digits, med, digits, iqr)
  )
}

# ============================================
# Visualization Helper Functions
# ============================================

#' Scale values to 0-1 range for radar charts
#' @param x numeric vector
#' @param min_val minimum value (default: min of x)
#' @param max_val maximum value (default: max of x)
#' @return scaled numeric vector
scale_to_01 <- function(
  x,
  min_val = min(x, na.rm = TRUE),
  max_val = max(x, na.rm = TRUE)
) {
  if (max_val == min_val) {
    return(rep(0.5, length(x)))
  }
  (x - min_val) / (max_val - min_val)
}

#' Convert z-scores to 0-1 scale for radar charts
#' @param z numeric vector of z-scores
#' @param min_z minimum z-score for clipping
#' @param max_z maximum z-score for clipping
#' @return scaled numeric vector
z_to_radar_scale <- function(z, min_z = -2.5, max_z = 2.5) {
  z_clipped <- pmax(pmin(z, max_z), min_z)
  (z_clipped - min_z) / (max_z - min_z)
}

#' Apply APA-style theme to ggplot
#' @return ggplot theme object
theme_apa <- function() {
  ggplot2::theme_minimal(base_size = 11) +
    ggplot2::theme(
      plot.title = ggplot2::element_text(size = 12, face = "bold", hjust = 0),
      plot.subtitle = ggplot2::element_text(size = 10, hjust = 0),
      axis.title = ggplot2::element_text(size = 11),
      axis.text = ggplot2::element_text(size = 10),
      panel.grid.minor = ggplot2::element_blank(),
      panel.border = ggplot2::element_rect(
        fill = NA,
        color = "black",
        linewidth = 0.5
      ),
      panel.background = ggplot2::element_rect(fill = "white"),
      legend.position = "bottom"
    )
}
