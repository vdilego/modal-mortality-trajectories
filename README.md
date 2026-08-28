# Mortality Accumulation before the Modal Age at Death

Reproducible RStudio/GitHub project for a Population Studies manuscript asking:

> **Do populations with the same modal age at death reach it after accumulating the same amount of mortality?**

The central empirical object is the cumulative hazard at the modal age,

\[
H(M)=\int_0^M \mu(a)\,da,
\]

considered jointly with the conventional adult modal age at death `M`.

## Project structure

- `R/01_download_hmd.R` — downloads sex-specific HMD period life tables.
- `R/02_functions.R` — estimates `M`, `H(M)`, survival at `M`, `M_H`, and `Delta_M`.
- `R/03_build_metrics.R` — creates the population-year analytic dataset and exact sign checks.
- `R/04_matched_pairs.R` — finds population-years with nearly equal `M` but maximally different `H(M)`.
- `R/05_figures.R` — produces the main and diagnostic ggplot figures.
- `R/06_sensitivity.R` — evaluates sensitivity of the estimated mode to spline smoothing.
- `manuscript/main.tex` — first manuscript draft; Results and Discussion are provisional.
- `manuscript/refs.bib` — bibliography supplied with the project. 

## Reproducibility

1. Open `modal-mortality-trajectories.Rproj` in RStudio.
2. Copy `config.example.R` to `config.R`.
3. Put your HMD username/password in `config.R`. This file is ignored by Git.
4. Install the packages listed in `R/00_packages.R`.
5. Run `source("run_all.R")`.

The core outputs are:

- `data/derived/modal_metrics.csv`
- `data/derived/matched_pairs_contemporary.csv`
- `figures/fig1_M_HM_space.pdf`
- `figures/fig2_conditional_range.pdf`
- `figures/fig3_sweden_transition.pdf`
- `figures/fig4_matched_trajectories.pdf`


## Mathematical conventions

- `M`: conventional adult modal age at death.
- `H(x)`: cumulative hazard.
- `H(M)`: mortality accumulated before the modal age.
- `M_H = H^{-1}(1)`: age at cumulative hazard one.
- `Delta_M = M - M_H`.

The project keeps the sign convention above throughout. Since `H(x)` is increasing,

\[
\operatorname{sign}(\Delta_M)=\operatorname{sign}[H(M)-1]
\]

exactly. The scripts verify this identity for every estimated population-year.
