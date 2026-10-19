# Not All Play is Equal: In-game Player Behaviour Predicts Wellbeing Differences

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.23468927.svg)](https://doi.org/10.5281/zenodo.23468927)
[![License: CC BY 4.0](https://img.shields.io/badge/License-CC_BY_4.0-lightgrey.svg)](https://creativecommons.org/licenses/by/4.0/)

Analysis code and manuscript source for our article in *ACM Games: Research and Practice* (accepted). Read the authors' version: [HTML](https://thomhak.github.io/playstyle-article/) · [Preprint PDF](https://thomhak.github.io/playstyle-article/manuscript.pdf) · [ACM version PDF](https://thomhak.github.io/playstyle-article/manuscript-acm.pdf) · [Word](https://thomhak.github.io/playstyle-article/manuscript.docx)

**Authors:** [Thomas Hakman](https://thomashakman.com/) (University of Oxford), [Matti Vuorre](https://vuorre.com/) (Tilburg University), [Andrew K. Przybylski](https://www.przybylski.xyz/) (University of Oxford)

## Citation

> Hakman, T., Vuorre, M., & Przybylski, A. K. (in press). Not all play is equal: In-game player behaviour predicts wellbeing differences. *Games: Research and Practice*.

The code is archived on Zenodo: <https://doi.org/10.5281/zenodo.23468927>.

## Data

The data come from Johannes, Vuorre, and Przybylski ([2021](https://doi.org/10.1098/rsos.202049)) and are available on [OSF](https://doi.org/10.17605/OSF.IO/CJD6Z) under CC BY 4.0. They are not included in this repository.

## Reproduce

1. Download `ea.zip` from [OSF](https://osf.io/cjd6z/files/4gp3r) and extract it into `data/raw/ea/`.
2. Run `quarto render preprocessing_new.qmd` to create `data/pvz_clean_final.csv`.
3. Run `quarto render manuscript.qmd --to html` (other formats: `acm-pdf`, `preprint-typst`, `preprint-docx`). Add `-P refit_models:false` to reuse cached models.

Results were produced with R 4.5.1 and Quarto 1.9.38; the ACM PDF also needs LaTeX.

## Licence

[CC BY 4.0](LICENSE). Questions: [open an issue](https://github.com/Thomhak/playstyle-article/issues) or email thomas.hakman@oii.ox.ac.uk.
