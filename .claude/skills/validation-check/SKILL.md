---
name: validation-check
description: Compare one named model to both baselines on H1 only. Use before freezing a forecast change.
argument-hint: "[ridge or hgb]"
allowed-tools: Bash(make validate)
---

Requested model: $ARGUMENTS

Run `make validate` from the repo root. Read the validation R² and MAE
for the requested model and both baselines. Quote the three pairs and
say which model has the smallest mean absolute error. If the argument
is neither ridge nor hgb, ask for one of those names. Stop after the
comparison. Do not evaluate H2 or edit any files.
