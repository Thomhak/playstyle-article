# Not All Play is Equal: In-game Player Behaviour Predicts Wellbeing Differences

[![DOI](https://zenodo.org/badge/1156426724.svg)](https://doi.org/10.5281/zenodo.23468927)

This repo contains the analysis code and manuscript source for our paper, accepted in *ACM Games: Research and Practice*.

The rendered manuscript (HTML, PDF, DOCX) can be viewed at <https://thomhak.github.io/playstyle-article/>.

- The analysis code is archived on Zenodo: <https://doi.org/10.5281/zenodo.23468927> (DOI for all versions)
- GitHub: <https://github.com/Thomhak/playstyle-article>

**Authors:** Thomas Hakman (University of Oxford), Matti Vuorre (Tilburg University), Andrew K. Przybylski (University of Oxford)

## Reproduce

1. Clone the repository.
2. Download the raw data from [OSF](https://osf.io/cjd6z/files/4gp3r). The download is a single archive (`ea.zip`); extract it so that the files sit directly in `data/raw/ea/`. The code needs `Oxford PvZ - Pilot Wave + Wave 1 Download.xlsx` and the `OII_PVZ_Authentications`, `OII_PVZ_Character` and `OII_PVZ_Game_Time` files (each as `<name>.csv` and `<name>_p2.csv`).
3. Run the preprocessing, which writes `data/pvz_clean_final.csv` (the analysis file, n = 470) and intermediate files in `data/processed/`:
   ```bash
   quarto render preprocessing_new.qmd
   ```
4. Render the manuscript. A plain `quarto render manuscript.qmd` renders all four formats (HTML, Typst preprint, Word, ACM PDF) and refits the robust mixed models, because `refit_models` defaults to `true`. To render one format:
   ```bash
   quarto render manuscript.qmd --to html
   ```
   To reuse fitted models from `output/models/` (missing models are fitted automatically), add `-P refit_models:false`. The ACM PDF (`--to acm-pdf`) needs a LaTeX installation. The manuscript also reads the raw `OII_PVZ_Game_Time` files for the session counts, so keep `data/raw/ea/` in place.

## Software used

R 4.5.1, Quarto 1.9.38 and TeX Live 2025, with dplyr 1.1.4, readr 2.1.5, tidyr 1.3.1, cluster 2.1.8.1, fpc 2.2-13, factoextra 1.0.7, robustlmm 3.3-3, lme4 1.1-37 and tinytable 0.14.0.7. Packages are installed with `pacman::p_load()`, which installs current CRAN versions; results were produced with the versions listed here.

## License

Creative Commons Attribution 4.0 International (CC BY 4.0).
