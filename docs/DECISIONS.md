# Decisions

One line per methodological decision: what you chose, why, and what it changed.
Agents append here via the `/new-feature` skill; you append here by hand.

- Exclude `casual`, `registered`: they sum to `cnt` exactly. Leaky model R^2 1.000 -> honest ridge 0.583.
- Exclude `cnt_2d_bfr`: a shipped 2-day lag we cannot test the alignment of. Build our own lags instead.
- Exclude `instant`, `yr`, `days_since_2011`: time indexes let a tree predict a flat constant past 2011 and a linear model extrapolate a trend we have no grounds for.
- Split 2011 / H1 2012 / H2 2012 by date. Test set touched once, after all feature work.
- Report mean and persistence baselines with every score. Persistence (test R^2 0.510, MAE 840) is within 0.07 R^2 of ridge and beats it on MAE; that caveat goes in the report.

Entries below distinguish the student's instructions from agent proposals. The five entries above are the course starter's reference decisions and numbers.

- 2026-11-17 · Student instruction, implemented by Codex in `Reserve H2 for the frozen comparison`. Use H1 alone for selection. Move the starter's model-performance test to H1, retaining its R² floor and explicitly comparing the mean. Baseline H1 Ridge 0.6475 and HGB 0.2185 (348 training and 182 validation days).
- 2026-11-17 · Codex proposal before fitting, same commit. Test yesterday's temperature as a predictor. It is observed by the end of d−1 and can help interpret yesterday's count during weather changes. Use Ridge validation R² as the retention criterion (gain of at least 0.01 per starter skill), report HGB too. Compare a single additive target residual against the preceding week's mean for both model families, with unchanged estimators and training dates.
- 2026-11-17 · Codex recommendation, pending student endorsement (test `a0b5067`, feature `164b926`). Retain yesterday's temperature for the reference Ridge comparison. H1 Ridge R² rose 0.6475 → 0.6951 (+0.0476), MAE fell 832.9 → 746.1. HGB deteriorated 0.2185 → 0.1936 (−0.0249). Identical 348/182 rows; a one-day lag leaves the seven-day warm-up intact.
- 2026-11-17 · Codex recommendation, experiment `65b27a6`, freeze in `Freeze feature and weekly-residual choice on H1`. Use the preceding seven-day mean as a known local demand level. Fit residuals and add the mean back for both estimators. H1 residual HGB 0.7261/704.5 and residual Ridge 0.7034/732.1 (R²/MAE). Freeze all settings and evaluate both untransformed feature sets and the two residual models on H2 in one final evaluation stage. Future reruns are reproducibility checks.
- 2026-11-17 · Codex workflow decision (`d749f01`, `cf67b6e`, `4ed3d1e`). Document H1-only commands, prior-day temperature, weather timing, dual baselines and raw SHA-256. Keep the custom validation skill separate from the starter skill. These change enforcement and interpretation, not the measured forecast.
