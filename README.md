# Not All Play is Equal: In-game Player Behaviour Predicts Wellbeing Differences

[![DOI](https://zenodo.org/badge/1156426724.svg)](https://doi.org/10.5281/zenodo.23468927)

This repo contains the analysis code and manuscript source for our paper.

The rendered manuscript (HTML, PDF, DOCX) can be viewed at <https://thomhak.github.io/playstyle-article/>.

- The analysis code is archived on Zenodo: <https://doi.org/10.5281/zenodo.23468927> (DOI for all versions)
- GitHub: <https://github.com/Thomhak/playstyle-article>

**Authors:** Thomas Hakman (University of Oxford), Matti Vuorre (Tilburg University), Andrew K. Przybylski (University of Oxford)

## Reproduce

1. Clone the repository.
2. Download the raw data from [OSF](https://osf.io/cjd6z/files/4gp3r) into `data/raw/ea/`.
3. Run preprocessing: `quarto render preprocessing_new.qmd`
4. Render the manuscript:
   ```bash
   quarto render manuscript.qmd -P refit_models:true -P rerun_clustering:true
   ```
   Subsequent renders use cached models: `quarto render manuscript.qmd`

## License

Creative Commons Attribution 4.0 International (CC BY 4.0).
