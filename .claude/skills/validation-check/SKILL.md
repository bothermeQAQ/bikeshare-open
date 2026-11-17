---
name: validation-check
description: Score one named model and its two baselines on H1 only.
argument-hint: "[ridge or hgb]"
allowed-tools: Bash(make validate-ridge), Bash(make validate-hgb)
---

Read the requested name: $ARGUMENTS

- For ridge, run exactly `make validate-ridge`.
- For hgb, run exactly `make validate-hgb`.
- For anything else, request one of the two supported names.

Return the final output line, including both baselines and the lowest MAE.
Each command computes only the requested comparison for display. Do not
change the command, rank the models yourself or read held-out results.
