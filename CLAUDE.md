# Daily Capital Bikeshare forecasts

Predict the next day's total rides (`cnt`). The starter's weather inputs are
daily observations. Interpret weather-dependent results as conditional on
having forecast-quality weather at the decision time.

- Run `make validate` or `/validation-check ridge` (also accepts `hgb`) while
  selecting features and transformations. Run `make test` before each claim.
- Freeze decisions in `docs/DECISIONS.md` before evaluating H2. Run `make all`
  for the final untransformed results, including the original feature set.
- Split by calendar date: 2011 train, H1 2012 validation, H2 2012 test.
  Fit scalers and estimators on 2011 only.
- Report the training-mean and yesterday-count baselines with Ridge and HGB.
- Never offer `cnt`, `casual`, or `registered` as predictors. The latter two
  sum to the target. Exclude identifiers, raw time indexes and the unverified
  mirror lag via `FORBIDDEN`. Review each new physical CSV column separately.
- Preserve the checked-in CSV and its hash. Classify new sources in a
  separate revision before using them.
- Use `/new-feature` and commit a failing named-date test before implementation.
  Reindex to calendar days before shifting, shift before aggregation, and
  maintain the maximum lookback in `LAG_WARMUP`. Yesterday's temperature
  must come from d−1 even when an observation is absent.
- Keep requirements pinned. Use the counts reconstructed on the original
  rides scale for both metrics in the target experiment.
