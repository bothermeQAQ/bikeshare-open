"""Compare a count forecast with a forecast of departures from recent demand.

Default evaluation is H1 only. The --final option also describes H2 after
the protocol is frozen. All fitted objects see 2011 only.
"""
import argparse
import json

import numpy as np
import pandas as pd
from sklearn.base import clone

from src.config import PROCESSED, TARGET, VALID_END
from src.features import feature_columns
from src.train import MODELS, scores, temporal_split


def experiment(final=False):
    frame = pd.read_parquet(PROCESSED)
    if not final:
        frame = frame.loc[frame.dteday <= VALID_END]
    train, valid, test = temporal_split(frame)
    periods = {"valid": valid}
    if final:
        periods["test"] = test
    cols = feature_columns(frame)
    result = {"train_count_range": [int(train.cnt.min()), int(train.cnt.max())]}
    for name, part in periods.items():
        result[name] = {
            "days": len(part),
            "above_train_max": int((part.cnt > train.cnt.max()).sum()),
            "count_range": [int(part.cnt.min()), int(part.cnt.max())],
            "mean_count": round(float(part.cnt.mean()), 1),
        }

    for model_name in ("ridge", "hgb"):
        for transform in ("level", "weekly_residual"):
            y_train = train[TARGET]
            if transform == "weekly_residual":
                y_train = y_train - train.cnt_roll_7
            model = clone(MODELS[model_name]).fit(train[cols], y_train)
            for name, part in periods.items():
                prediction = model.predict(part[cols])
                if transform == "weekly_residual":
                    prediction += part.cnt_roll_7.to_numpy()
                result[name][f"{model_name}_{transform}"] = scores(part.cnt, prediction)
                if model_name == "ridge" and transform == "level":
                    errors = np.abs(part.cnt - prediction)
                    persistence = np.abs(part.cnt - part.cnt_lag_1)
                    result[name]["ridge_smaller_absolute_error_days"] = int((errors < persistence).sum())
                    result[name]["largest_absolute_error"] = {
                        "ridge": round(float(errors.max()), 1),
                        "persistence": round(float(persistence.max()), 1),
                    }
                    result["ridge_standardized_coefficients"] = {
                        key: round(float(value), 1) for key, value in zip(cols, model[-1].coef_)
                    }
    return result


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--final", action="store_true")
    print(json.dumps(experiment(parser.parse_args().final), indent=2))
