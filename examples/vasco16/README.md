# Vasco16 Examples

This folder contains two synthetic examples for the Ahlgren et al. (2016)
FC/NC IVIM velocity-dispersion model.

Files:

- `demo_vasco16_fit_and_plot.m`
  - fits one synthetic FC/NC signal
  - plots FC and NC data together with the fitted curves
  - can optionally run a noiseless `v_d` recovery scan

- `demo_vasco16_fit_evaluation.m`
  - compares unregularized, regularized, and two-stage fitting
  - evaluates parameter bias, variability, and signal RMSE on a synthetic grid
  - with `do_generate = 1`, generates and saves cached results
  - with `do_generate = 0`, reloads cached results and replots without recomputing fits

- `data/bipolar_fc_xps.mat`
  - precomputed `xps` structure for the bipolar FC/NC encoding scheme used by the examples

Generated output is written to `output/`.

Notes:

- Both scripts call `setup_paths` automatically from the repo root.
- `xps` can be generated from single gradient waveforms with `gwf_to_pars`.
- For multiple waveforms, per-waveform `xps` structures can be combined with
  `mdm_xps_merge`.
