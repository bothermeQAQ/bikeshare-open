# Forecasting daily Capital Bikeshare demand

## Results

Each forecast is for one day, with the previous day's count already available. Models fit 348 eligible days in 2011. Validation covers 182 days in January–June 2012 and the held-out comparison covers 184 days in July–December 2012. MAE is in rides per day. Each R² uses the corresponding evaluation period's mean in its denominator. Both feature sets use identical dates, estimators and training data. The added input is the previous calendar day's observed temperature.

| Feature set | Model | Validation R² | Validation MAE | Test R² | Test MAE |
|---|---|---:|---:|---:|---:|
| Before | baseline_mean | -0.9318 | 2002.2 | -2.1441 | 2847.7 |
| Before | baseline_persistence | 0.4507 | 900.6 | 0.5099 | 840.1 |
| Before | ridge | 0.6475 | 832.9 | 0.5833 | 947.1 |
| Before | hgb | 0.2185 | 1296.6 | -0.4975 | 1972.6 |
| After | baseline_mean | -0.9318 | 2002.2 | -2.1441 | 2847.7 |
| After | baseline_persistence | 0.4507 | 900.6 | 0.5099 | 840.1 |
| After | ridge | 0.6951 | 746.1 | 0.6238 | 876.6 |
| After | hgb | 0.1936 | 1321.1 | -0.5785 | 2036.7 |

The untransformed results are reproducible with `make all`. The original feature set is nested under `before_feature` in `reports/metrics.json`. Reindexing the daily calendar exposes the hole on March 10, 2011. Seven initial days and seven raw observations after the gap lack complete histories, leaving 714 of 728 observations. The extra temperature lag uses one day and costs no additional rows.

The final SDK self-audit found no leakage and confirmed the temporal split, baselines and reproducibility. It questioned the one-day shift in the seven-day mean. For forecast day *d*, shifting one day and averaging seven uses exactly *d−7* through *d−1*. Shifting seven days first would use *d−13* through *d−7*, discarding six available days. An independent calculation from raw counts matched all 714 seven-day means exactly. We retained the original window. The machine output is in `reports/audit.jsonl`, and the earlier audit and its evidence-based response remain in commits `cd82ff1` and `c51dc28`.

## Headline finding

The model given casual and registered rides scores **1.000000** on H2 because these counts sum exactly to the target. In the forecast comparison the training mean achieves **−2.1441**, yesterday's count **0.5099**, and Ridge with yesterday's temperature **0.6238**. Untransformed HGB scores **−0.5785** and still improves on the training mean. Growth changes the comparison: 104 of 184 H2 counts exceeded the largest eligible 2011 count of 6,043, and the mean H2 count of 6,042.9 nearly reached that maximum. Yesterday's temperature increased H1 Ridge R² by **0.0476** and lowered HGB R² by **0.0249**. Ridge was the prespecified retention criterion, so the agent recommended keeping the feature before opening H2.

## Exercise 4: target transformation

For date *d* define *m(d)* as the mean demand on the seven calendar days ending at *d−1*. Train each model on *y(d) − m(d)* and add *m(d)* back to its prediction. A tree can then forecast demand above the historical training range by adding a learned correction to a recently observed level. It need not extrapolate a trend in calendar time. A boosted sum of trees has no general mathematical ceiling at the largest training target. Its piecewise-constant response outside learned split thresholds is the relevant limitation here.

Both models received the same 15 inputs, the same rolling mean, identical dates and their original hyperparameters. Ridge scaling used only 2011. On the original rides scale the transformed HGB achieved **0.7261 R² / 704.5 MAE** on H1, versus **0.7034 / 732.1** for transformed Ridge. Subtracting the mean changed the target for both. It also supplies a coefficient of one on that mean at reconstruction, which helps explain why even regularized Ridge can change slightly. The feature and transformation choices were frozen in `5d0333d` before one final H2 comparison. On H2, transformed HGB scored **0.6426 / 819.8**, transformed Ridge **0.6300 / 862.3**. The frozen numerical reproduction command is `python -m src.target_experiment --final`.

The transformation is defensible for rolling one-day-ahead service: yesterday's completed counts are observable even on later days of a held-out period. A batch forecast made on July 1 for all of H2 would require a different experiment. The shared limitation is the starter's use of realized same-day weather, including temperature and humidity. Archived forecasts issued before the decision are needed to estimate operational performance. Validation had 71 of 182 counts above the training maximum, so growth already mattered in H1. These two six-month periods give no estimate of performance in another year or city.

## Exercise 5: ridge vs persistence

Keep persistence as the default if a one-ride allocation error has roughly constant cost. H1 favored Ridge on both metrics, but on H2 its MAE was **876.6** versus **840.1**, an extra **36.5 rides per day**. Ridge had the smaller absolute error on only **82 of 184 days**. Its R² advantage of **0.1139** and lower maximum absolute error (**4,166.5** vs **4,470.0**) support a different choice for an operator who puts disproportionate weight on large misses. Ridge draws on the trailing weekly mean, yesterday's count and temperature changes: their standardized count-scale coefficients include +613.0 for the weekly mean, +378.0 for yesterday's count, +518.4 for today's temperature and −515.2 for yesterday's. These correlated coefficients describe the fitted predictor and do not identify causal weather effects. Persistence needs only the last count and can operate without a weather feed. The cost assumption is an agent recommendation pending operator or student confirmation.

## Attribution

Codex (GPT-6 family, parameter count unavailable) and Claude Code 2.1.156 with local Ollama 0.40.16 were used. The initial Qwen3.5 9B build passed a short tool check but ran out of Metal memory in a full Claude session. The local agent switched to Qwen3.5 4B with the same configured 65,536-token context. For the peer review on November 19, the Qwen3.5 4B subagent read the peer files but stalled. The completed review used the same named reviewer with local Qwen2.5 3B, CPU inference and a 32,768-token context. The full answer and separate evidence-based assessment are in `docs/AUDIT.md`. The Agent SDK version is 0.2.172 with bundled Claude Code 2.1.308. The open-weight model sizes are Ollama tag designations.

- **Agent work.** The course supplied the data, original pipeline, split, baselines, hook, feature skill and auditor. Local Claude used the feature skill, drafted the first test and edited `build_features`. Codex corrected the model's fixture, date and column selection and discarded a contradictory absence assertion. Codex implemented the schema, alias and hash checks, validation-only scoring, paired comparisons, target experiment, custom skill, auditor compatibility changes and documentation. Fault evidence and SDK output are identified separately in `docs/SEEDED_FAULTS.md` and `reports/audit.jsonl`.
- **Student decisions.** The student expressly required validation-only selection, one final holdout comparison, preservation of the untransformed results, and honest attribution. The student supplied the peer repository on November 19 after initially deferring the classmate audit. The temperature feature, residual transformation, retention rule application and deployment recommendation were proposed and evaluated by the agents. Student endorsement of those scientific judgments is pending. The five original lines of `docs/DECISIONS.md` came from the starter.
