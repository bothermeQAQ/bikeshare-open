---
name: validation-check
description: Compare a named model with the mean and persistence baselines on H1 only.
argument-hint: "[ridge or hgb]"
allowed-tools: Bash(make validate)
---

Requested model: $ARGUMENTS

The following validation results are generated at invocation time.

!`make validate`

Select the requested model from this output. Quote its validation R²
and MAE alongside baseline_mean and baseline_persistence and identify
the smallest MAE among these three entries. For a name other than
ridge or hgb, request a valid model name. The argument selects a row
in the output and is never inserted into a shell command. The command
above has already run. Answer directly without another tool call.
