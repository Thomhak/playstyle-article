# Player Playstyle Analysis

This project analyzes the relationship between player playstyles, game performance metrics, and well-being outcomes using data from Plants vs. Zombies: Battle for Neighborville.

## Project Organization

The project is organized into the following structure:

```
├── 1_preprocessing.qmd     # Data preprocessing and cleaning
├── 2_analysis.qmd          # Analysis and visualization
├── data/
│   ├── processed/          # Processed data files
│   └── raw/                # Raw data files
├── figures/                # Generated figures
├── scripts/
│   └── helper_functions.R  # Helper functions for data processing and analysis
└── README.md               # This file
```

## Usage

This project is organized into two main Quarto documents:

1. `1_preprocessing.qmd`: Contains all data preprocessing steps, including loading raw data, cleaning, feature engineering, and saving processed datasets. Run this file first to generate the processed data files.

2. `2_analysis.qmd`: Contains the analysis of the preprocessed data, including exploratory data analysis, player clustering, and well-being analysis. This file uses the processed data from the first file.

## Workflow

Follow these steps to reproduce the analysis:

1. Run `1_preprocessing.qmd` first to generate all the processed datasets.
2. Run `2_analysis.qmd` to perform the analysis and generate visualizations.

## Data Description

The data comes from a study conducted by EA and the Oxford Internet Institute. Players completed a survey on well-being and motivations, and EA provided telemetry data on their gameplay. The analysis combines these two data sources to examine the relationship between playstyles and well-being.

## Dependencies

This project requires the following R packages:

- tidyverse
- here
- lubridate
- scales
- janitor
- magrittr
- psych
- readxl
- knitr
- corrplot
- ggpubr
- factoextra
- cluster
- fmsb

To install all required packages, run:

```r
install.packages(c(
  "tidyverse", "here", "lubridate", "scales", "janitor",
  "magrittr", "psych", "readxl", "knitr", "corrplot",
  "ggpubr", "factoextra", "cluster", "fmsb"
))
```
