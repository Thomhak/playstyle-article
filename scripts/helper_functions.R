# Helper functions for PvZ data analysis
# These functions support the main analysis in playstyle_analysis.qmd

# Function to read both waves of telemetry data into a single table
read_both_waves <- function(stub = "OII_PVZ_Authentications", data_dir = "data/raw/ea", ...) {
  # Filenames of wave 1 and 2 authentications files
  list.files(
    here::here(data_dir), pattern = stub, full.names = TRUE
  ) %>% 
    # Put wave 1 first (they are in reverse order)
    rev() %>% 
    # Read into a list of data frames
    purrr::map(readr::read_csv, ...) %>% 
    # Bind into one data frame with wave ID
    dplyr::bind_rows(.id = "wave")
}

# Function to create performance metrics from player data
calculate_performance_metrics <- function(df, prefix = "total") {
  # Handle cases where denominators might be zero
  df <- df %>%
    dplyr::mutate(
      # Set death count to 1 if 0 to avoid division by zero
      dplyr::across(
        dplyr::contains("death_count"), 
        ~ ifelse(.x == 0, 1, .x)
      )
    )
  
  # Create column names based on prefix
  kill_count_col <- paste0(prefix, ifelse(prefix == "", "", "_"), "kill_count")
  death_count_col <- paste0(prefix, ifelse(prefix == "", "", "_"), "death_count")
  shots_hit_col <- paste0(prefix, ifelse(prefix == "", "", "_"), "shots_hit")
  shots_fired_col <- paste0(prefix, ifelse(prefix == "", "", "_"), "shots_fired")
  crit_hit_col <- paste0(prefix, ifelse(prefix == "", "", "_"), "critical_hit_count")
  damage_col <- paste0(prefix, ifelse(prefix == "", "", "_"), "damage_dealt")
  sessions_col <- paste0(prefix, ifelse(prefix == "", "", "_"), "sessions")
  seconds_col <- paste0(prefix, ifelse(prefix == "", "", "_"), "seconds")
  score_col <- paste0(prefix, ifelse(prefix == "", "", "_"), "score")
  
  # Calculate and return metrics
  df %>%
    dplyr::mutate(
      # KD ratio
      !!paste0(prefix, ifelse(prefix == "", "", "_"), "kd") := 
        .data[[kill_count_col]] / .data[[death_count_col]],
      
      # Hit accuracy
      !!paste0(prefix, ifelse(prefix == "", "", "_"), "hit_accuracy") := 
        .data[[shots_hit_col]] / .data[[shots_fired_col]],
      
      # Critical hit ratio
      !!paste0(prefix, ifelse(prefix == "", "", "_"), "crit_ratio") := 
        .data[[crit_hit_col]] / .data[[shots_hit_col]],
      
      # Damage per second
      !!paste0(prefix, ifelse(prefix == "", "", "_"), "dps") := 
        .data[[damage_col]] / .data[[seconds_col]],
      
      # Damage per game
      !!paste0(prefix, ifelse(prefix == "", "", "_"), "average_damage") := 
        .data[[damage_col]] / .data[[sessions_col]],
      
      # Score per second
      !!paste0(prefix, ifelse(prefix == "", "", "_"), "sps") := 
        .data[[score_col]] / .data[[seconds_col]],
      
      # Score per game
      !!paste0(prefix, ifelse(prefix == "", "", "_"), "average_score") := 
        .data[[score_col]] / .data[[sessions_col]]
    ) %>%
    # Replace NaN with 0
    dplyr::mutate(
      dplyr::across(
        tidyselect::everything(), 
        ~ ifelse(is.nan(.x), 0, .x)
      )
    )
}

# Function to summarize mode-specific playing time
summarize_mode_hours <- function(df, mode_col, start_col = "game_start_time", end_col = "game_end_time") {
  df %>%
    dplyr::filter(.data[[mode_col]] == 1) %>%
    dplyr::mutate(duration = .data[[end_col]] - .data[[start_col]]) %>%
    dplyr::mutate(seconds = as.numeric(duration)) %>%
    dplyr::group_by(player_id) %>%
    dplyr::summarise(
      seconds = sum(seconds, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    dplyr::mutate(hours = seconds / 60 / 60) %>%
    dplyr::rename_with(
      ~ paste0(gsub("_session", "", mode_col), "_", .),
      c(seconds, hours)
    )
}

# Function to calculate SPANE scales
calculate_spane <- function(df, prefix = "spane") {
  positive_items <- c(1, 3, 5, 7, 10, 12)
  negative_items <- c(2, 4, 6, 8, 9, 11)
  
  df %>%
    dplyr::mutate(
      # Positive affect
      !!paste0(prefix, "_positive") := rowMeans(
        dplyr::select(
          .,
          paste0(prefix, "_", positive_items)
        ),
        na.rm = TRUE
      ),
      # Negative affect
      !!paste0(prefix, "_negative") := rowMeans(
        dplyr::select(
          .,
          paste0(prefix, "_", negative_items)
        ),
        na.rm = TRUE
      ),
      # Affect balance
      !!paste0(prefix, "_balance") := .data[[paste0(prefix, "_positive")]] - 
        .data[[paste0(prefix, "_negative")]]
    )
}

# Function to create motivation scales
calculate_motivation_scales <- function(df) {
  df %>%
    dplyr::mutate(
      autonomy = rowMeans(
        dplyr::select(., dplyr::starts_with("autonomy_")), 
        na.rm = TRUE
      ),
      competence = rowMeans(
        dplyr::select(., dplyr::starts_with("competence_")), 
        na.rm = TRUE
      ),
      relatedness = rowMeans(
        dplyr::select(., dplyr::starts_with("relatedness_")), 
        na.rm = TRUE
      ),
      enjoyment = rowMeans(
        dplyr::select(., dplyr::starts_with("enjoyment_")), 
        na.rm = TRUE
      ),
      extrinsic = rowMeans(
        dplyr::select(., dplyr::starts_with("extrinsic_")), 
        na.rm = TRUE
      )
    )
}

# Function to plot session timeline for a player
plot_player_sessions <- function(player_data, player_label = "Player") {
  player_data %>%   
    dplyr::mutate(row_id = dplyr::row_number()) %>% 
    ggplot2::ggplot(
      ggplot2::aes(
        x = start_time_only, 
        y = row_id, 
        color = match_type
      )
    ) +
    ggplot2::scale_color_manual(
      name = "Match type", 
      breaks = c(
        "social match",
        "pve match",
        "pvp match (rush)",
        "pvp match (vanquish)",
        "pvp match (arena)",
        "podium celebration"
      ),
      values = c(
        "#2ECC71", "#4E7FE3", "#E74C3C", 
        "#F39C12", "#FFEE4B", "#9B59B6"
      )
    ) +
    ggplot2::geom_segment(
      ggplot2::aes(
        xend = end_time_only, 
        yend = row_id
      )
    ) +
    scales::scale_x_datetime(
      labels = scales::date_format("%H:%M"),
      breaks = scales::date_breaks("2 hours")
    ) +
    ggplot2::xlab("Time (hours)") + 
    ggplot2::ylab("Game matches") +
    ggplot2::theme(
      legend.position = "right", 
      axis.text.y = ggplot2::element_blank(),
      axis.ticks.y = ggplot2::element_blank(),
      panel.grid.major = ggplot2::element_blank(), 
      panel.grid.minor = ggplot2::element_blank(), 
      panel.background = ggplot2::element_blank(), 
      axis.line = ggplot2::element_line(colour = "black")
    ) +
    ggplot2::ggtitle(player_label)
} 