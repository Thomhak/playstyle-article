# The relationship between in-game player behaviour, performance, and well-being

This repository contains the data, materials, and code for our manuscript "The relationship between in-game player behaviour, performance, and well-being".

- preprint: TBC
- [This repository](https://github.com/Thomhak/playstyle-article) contains the analysis code and manuscript.

Authors:
- Thomas Hakman (Oxford Internet Institute, University of Oxford)
- Matti Vuorre (Tilburg University)

## Data

Raw data is not included in this repository. Download it from the [OSF repository](https://osf.io/cjd6z/files/4gp3r) and place files in `data/raw/ea/`.

**Original data source:**
> Johannes, N., Vuorre, M., Magnusson, K., & Przybylski, A. K. (2021). Video game play is positively correlated with well-being. *Royal Society Open Science*, 8(2), 202049. https://doi.org/10.1098/rsos.202049

## Reproduce

The analysis code is written in R. The source code of the manuscript (including all data wrangling, analysis, and a preprint template that can be rendered as PDF or DOCX) is in `manuscript.qmd`. Data preprocessing is in `preprocessing_new.qmd`. Shared helper functions are in `helpers.R`.

1. Clone the repository.
2. Download the raw data from [OSF](https://osf.io/cjd6z/files/4gp3r) into `data/raw/ea/`.
3. R packages are automatically installed via `pacman` when running the scripts.
4. Run preprocessing: `quarto render preprocessing_new.qmd`
5. Render the manuscript (first time, fits all models from scratch):
   ```bash
   quarto render manuscript.qmd -P refit_models:true -P rerun_clustering:true
   ```
6. Subsequent renders use cached models and are much faster:
   ```bash
   quarto render manuscript.qmd
   ```
## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
