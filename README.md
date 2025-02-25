# Playstyle and Well-being Analysis

This repository contains the analysis for investigating the relationship between player playstyles, performance metrics, and well-being outcomes in Plants vs. Zombies: Battle for Neighborville.

## Project Structure

The project is organized as follows:

```
playstyle_ms/
├── data/
│   ├── raw/           # Original data files
│   └── processed/     # Cleaned and processed data
├── figures/           # Output figures and visualizations
├── scripts/           # Helper scripts and functions
├── playstyle_analysis.qmd  # Main analysis document
├── references.bib     # Bibliography file
└── README.md          # This file
```

## Analysis Overview

The analysis consists of several main components:

1. **Data preparation**: Loading and cleaning survey and telemetry data
2. **Game mode classification**: Categorizing game sessions into PvP, PvE, and social hub activities
3. **Performance metrics calculation**: Deriving metrics like K/D ratio, hit accuracy, and damage per second
4. **Player clustering**: Identifying player types based on gameplay patterns
5. **Well-being analysis**: Examining the relationship between playstyles and well-being outcomes

## Requirements

The analysis uses the following R packages:

- tidyverse (for data manipulation and visualization)
- here (for file path management)
- lme4 (for mixed-effects models)
- factoextra (for clustering visualization)
- knitr (for document generation)
- ...and others specified in the main document

## Running the Analysis

To reproduce the analysis:

1. Clone this repository
2. Place the raw data files in the `data/raw/ea/` directory
3. Render the Quarto document:

```r
quarto render playstyle_analysis.qmd
```

## Data Sources

The data used in this analysis comes from:

- Survey data collected from PvZ players
- Telemetry data from Plants vs. Zombies: Battle for Neighborville
- Original data was collected by Electronic Arts and the Oxford Internet Institute

## License

This project is licensed under the terms of the MIT license.
