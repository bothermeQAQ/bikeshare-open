---
name: validation-check
description: Compare a named model with the mean and persistence baselines on H1 only.
argument-hint: "[ridge or hgb]"
allowed-tools: Bash(make validation-summary)
---

Requested model: $ARGUMENTS

The following validation results are generated at invocation time.

!`make validation-summary`

Return the single output line that begins with the requested model name.
It contains both baselines and the lowest-MAE model among the three.
For any other name request ridge or hgb. Do not recompute the ranking.
