Below is a detailed, step-by-step checklist on how to streamline and improve the code of /Users/thomashakman/Projects/Academic/playstyle_ms/Thesis Analysis 3.Rmd. Each top-level bullet corresponds to a major area of enhancement; sub-bullets give specific tasks. You can use this list as a roadmap to refactor, reorganize, and clarify the workflow in your R/Quarto analysis.

---

## **1. Project Structure & File Organization**

- [x] **Modularize the code into distinct scripts or Quarto sections**  
  - [x] Split the quarto script by logical steps: data loading/cleaning, data transformation, analysis, and visualization.   
  - [x] Use a single "main" Quarto script, ensuring your final report remains concise.

- [x] **Adopt a consistent folder structure**  
  - [x] Keep all raw-data input paths in one place (e.g. in a `here::here()` subfolder) and use relative paths.  
  - [x] Create a `data/` folder (for processed .rds/.csv files) separate from `data-raw/` (raw input).  
  - [x] Create a `results/` or `figures/` folder to save final plots and tables.

---

## **2. Code Style & Consistency**

- [x] **Use a style guide**  
  - [x] Apply a standardized style convention (e.g., the tidyverse style guide).  
  - [x] Ensure spacing, indentation, and line length are consistent.  
  - [x] Use snake_case or camelCase for naming variables and functions consistently.

- [x] **Eliminate or reduce extraneous comments and deprecated code**  
  - [x] Remove large blocks of commented-out code that are no longer needed.  
  - [x] Where comments are helpful, keep them short and to the point.

- [x] **Consistent naming of columns and variables**  
  - [x] Align the naming convention for both raw and derived variables (e.g., `pvp_time`, `pve_time`, `total_time` vs. `pvp_Hours`, `pve_Hours`, `Hours`).  
  - [x] Keep variable suffixes consistent (e.g. `_hours` vs. `_hrs` or `_time`).

- [x] **Use pipes more consistently**  
  - [x] Where possible, chain data-wrangling steps in pipelines to reduce intermediate objects.  
  - [x] Example: `survey %>% rename(...) %>% mutate(...) %>% ... -> final_survey`.

---

## **3. Data Loading & Cleaning**

- [x] **Wrap repeated code in functions**  
  - [x] Reading files for each wave (`read_both_waves()`) is a good start; do similar wrapping for standard cleaning processes you repeat (e.g., turning wide data into scales, reversing items).

- [x] **Streamline reading & merging raw files**  
  - [x] Store all relevant file paths in a single named list or `.yaml` so they are easily updated.  
  - [x] Confirm the order of wave files with fewer manual steps (avoid reversing or re-reversing file lists if possible).

- [x] **Combine repeated cleaning tasks**  
  - [x] Look for repeated steps like `filter(player_id %in% survey$player_id)` that appear multiple times. Possibly make a function `filter_by_survey_participants(df, survey)`.

- [x] **Validate data merges**  
  - [x] After `left_join()`, check how many rows were added/lost. Possibly use `anti_join()` to see which `player_id` were not matched.  
  - [x] Remove large `glimpse()` calls or wrap them in a single, final summary check.

---

## **4. Variable Creation & Transformation**

- [x] **Factor recoding in one place**  
  - [x] Move repeated `fct_recode(...)` calls into a single code chunk or helper function, especially if multiple data frames share the same factor cleaning.

- [x] **Use consistent naming**  
  - [x] Example: switch from `active_play_minutes` + `active_play_hours` to a single "playtime" measure.  
  - [x] Clarify that columns like `social_hub == 1` are booleans or numeric flags; consider making them logical (`TRUE/FALSE`).

- [x] **Manage reverse scoring systematically**  
  - [x] Put reverse scoring calls in a short function so the transformation is explicit (`reverse_scores()`).

- [x] **Consolidate the scale creations**  
  - [x] Consider a loop or a function that generates subscale means to avoid repeated lines with `rowMeans(...)`.  
  - [x] Example: `create_scale(df, prefix = "spane_", items_pos = c(1,3,5,7,10,12), items_neg = c(2,4,6,8,9,11), name = "spane")`.

---

## **5. Telemetry & Merging Data Frames**

- [x] **Use single pipeline for each major dataset**  
  - [x] Instead of intermediate objects like `game_time_test`, consolidate these steps into a single pipeline (i.e. read → mutate → group_by → summarize → ungroup → return).  
  - [x] De-duplicate code that calculates durations, merges with survey, filters 14 days, etc.

- [x] **Reduce repetitive code in game-time summaries**  
  - [x] All the `game_time_players_total`, `game_time_players_pvp`, etc. look very similar. Convert these into a single function with a parameter for the grouping condition (pvp/pve/social).  
  - [x] Example function signature: `summarize_mode_hours(df, mode_col = "pvp_session", start_col = "game_start_time", end_col = "game_end_time")`.

- [x] **Consistent approach for `NA` vs. 0**  
  - [x] Re-check the logic of replacing `NA` with `0`. In some cases, an `NA` might be meaningful (e.g., no data available vs. zero time played).  
  - [x] Potentially keep them as `NA` until final summarizing or modeling steps, or use an explicit sentinel column.

---

## **6. Derived Metrics & Scoring**

- [x] **Re-check K/D ratio logic**  
  - [x] The code sets `death_count == 0` to 1 to avoid Inf. This is a valid approach but consider distinguishing truly no deaths from single-death cases. Alternatively, incorporate small offsets (`+ 1e-6`) if you want a continuous measure.

- [x] **Centralize repeated skill/performance calculations**  
  - [x] The script calculates `kd`, `hit_ratio`, `crit_ratio`, `damage_per_second`, etc. for total and per-mode. Wrap them in a function: `calculate_performance_metrics(df, prefix)`.  
  - [x] Label each derived variable systematically, e.g., `pvp_kd`, `pvp_hit_ratio`, `pvp_crit_ratio`, `pvp_dps`.

- [x] **Consistent naming for aggregator columns**  
  - [x] `Seconds`, `Seconds_nona`, `Hours_nona` can be standardized into e.g., `total_seconds` vs. `clean_seconds`.

---

## **7. Statistical Analysis & Modeling**

- [x] **Simplify clustering steps**  
  - [x] Cluster code is split across multiple places (k-means, random data generation, etc.). Move the entire clustering chunk into a single section or an R script dedicated to clustering.  
  - [x] Keep only one "optimal number of clusters" approach (e.g., the `fviz_nbclust()` + elbow method) unless you specifically need to compare multiple methods.

- [x] **Use consistent naming for cluster**  
  - [x] The code calls them "clusters" in some places, "player_type" in others. Once decided, rename references consistently.

- [x] **Combine or reduce repeated regression segments**  
  - [x] Multiple lines of code do `lm(... ~ Hours * c_elite )`, `lm(... ~ Hours * c_pve_adventurers )`, etc. Instead, do a single model with multiple interactions or define a function `run_cluster_regressions(dv, df)`.  
  - [x] For large diagnostic plots (Tukey, Q-Q, AIC, etc.), combine them into fewer code blocks or a single summary function.

- [x] **Centralize random effects modeling**  
  - [x] The code tries multiple approaches (random intercept, random slope, etc.). Combine them in a single chunk with clearly labeled "Model 1," "Model 2," "Model 3" to show progressive complexity.  
  - [x] Summarize with a single `anova(m0, m1, m2)` call or a `tab_model(m0, m1, m2)` so readers see the model comparisons in one place.

---

## **8. Visualization & Reporting**

- [x] **Group related plots into cohesive functions**  
  - [x] Many repeated calls to `ggplot` with the same aesthetics or only minor changes. Create short wrappers or a standard plotting theme to reduce duplication.  
  - [x] Possibly store repeated color scales in a global object, e.g., `myColors = scale_color_manual(...)`.

- [x] **Limit repeated histogram/frequency code**  
  - [x] If you are frequently visualizing `oii.freq(...)` or histograms, do it once in an exploratory chunk or remove it if no longer needed.

- [x] **Label plots consistently**  
  - [x] Standardize the x and y labels, especially for time-based variables (`"Hours (2-week period)"`, `"Wellbeing (SPANE balance)"`, etc.).  
  - [x] Ensure legends reflect the final cluster naming (e.g. "Cluster 1: PVP Elite").

---

## **9. Reproducibility & Performance**

- [x] **Set random seeds**  
  - [x] For clustering or random data checks, add `set.seed(...)` once at the start so results are reproducible.

- [x] **Cache expensive steps**  
  - [x] If using Quarto/R Markdown, consider `cache=TRUE` only for large transformations or modeling that doesn't change often.  
  - [x] For big merges or cluster calculations, save intermediate `.rds` files and re-load them if unchanged.

- [x] **Remove large or extraneous debugging calls**  
  - [x] Calls like `glimpse(...)`, `oii.summary(...)` for the entire data can be done selectively or put behind an `if (debug)` flag.

---

## **10. Documentation & Clarity**

- [x] **Add high-level commentary**  
  - [x] At the start of each major section (data cleaning, modeling, clustering, etc.), add a short comment explaining the goal of that section.  
  - [x] Avoid burying the rationale for steps in the middle of code blocks—summarize them in text.

- [x] **Use Quarto features**  
  - [x] Instead of large code blocks, break them into smaller code chunks with explanatory markdown text in between.  
  - [x] Insert references or citations (e.g., "(Gelman & Hill, 2006)") for the modeling approach or expansions of multi-level modeling.

- [x] **Ensure final report is linear**  
  - [x] Let the final .qmd read top-to-bottom, from data import to analysis to conclusion, to help collaborators or reviewers follow easily.

