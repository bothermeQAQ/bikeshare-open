# Controlled regressions

## Feature test before implementation

The suite was run against the candidate test and the unchanged feature builder. The numeric oracle is the observed temperature on January 9, 2011 for a forecast dated January 10.

```text
python -m pytest tests/ -q
............F.....                                                       [100%]
=================================== FAILURES ===================================
__________________ test_yesterdays_temperature_on_january_10 ___________________

self = Index(['instant', 'season', 'yr', 'mnth', 'holiday', 'weekday', 'temp',
       'atemp', 'hum', 'windspeed', 'casual', ...kday', 'month_sin', 'month_cos',
       'weather_severity', 'cnt_lag_1', 'cnt_lag_7', 'cnt_roll_7'],
      dtype='str')
key = 'temp_lag_1'

    def get_loc(self, key):
        """
        Get integer location, slice or boolean mask for requested label.
    
        Parameters
        ----------
        key : label
            The key to check its location if it is present in the index.
    
        Returns
        -------
        int if unique index, slice if monotonic index, else mask
            Integer location, slice or boolean mask.
    
        See Also
        --------
        Index.get_slice_bound : Calculate slice bound that corresponds to
            given label.
        Index.get_indexer : Computes indexer and mask for new index given
            the current index.
        Index.get_non_unique : Returns indexer and masks for new index given
            the current index.
        Index.get_indexer_for : Returns an indexer even when non-unique.
    
        Examples
        --------
        >>> unique_index = pd.Index(list("abc"))
        >>> unique_index.get_loc("b")
        1
    
        >>> monotonic_index = pd.Index(list("abbc"))
        >>> monotonic_index.get_loc("b")
        slice(1, 3, None)
    
        >>> non_monotonic_index = pd.Index(list("abcb"))
        >>> non_monotonic_index.get_loc("b")
        array([False,  True, False,  True])
        """
        casted_key = self._maybe_cast_indexer(key)
        try:
>           return self._engine.get_loc(casted_key)
                   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.venv/lib/python3.12/site-packages/pandas/core/indexes/base.py:3641: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
pandas/_libs/index.pyx:168: in pandas._libs.index.IndexEngine.get_loc
    ???
pandas/_libs/index.pyx:197: in pandas._libs.index.IndexEngine.get_loc
    ???
pandas/_libs/hashtable_class_helper.pxi:7668: in pandas._libs.hashtable.PyObjectHashTable.get_item
    ???
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

>   ???
E   KeyError: 'temp_lag_1'

pandas/_libs/hashtable_class_helper.pxi:7676: KeyError

The above exception was the direct cause of the following exception:

feats =         dteday  instant  season  ...  cnt_lag_1 cnt_lag_7   cnt_roll_7
0   2011-01-10     10.0  WINTER  ...      822.0...    1787.0  1530.142857
713 2012-12-31    731.0  WINTER  ...     1796.0     920.0  1531.428571

[714 rows x 28 columns]

    def test_yesterdays_temperature_on_january_10(feats):
        """Raw Jan 9 temperature was -1.498349; Jan 10 was -0.910849."""
        row = feats.set_index("dteday").loc[pd.Timestamp("2011-01-10")]
>       assert row["temp_lag_1"] == pytest.approx(-1.498349)
               ^^^^^^^^^^^^^^^^^

tests/test_leakage.py:72: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
.venv/lib/python3.12/site-packages/pandas/core/series.py:959: in __getitem__
    return self._get_value(key)
           ^^^^^^^^^^^^^^^^^^^^
.venv/lib/python3.12/site-packages/pandas/core/series.py:1046: in _get_value
    loc = self.index.get_loc(label)
          ^^^^^^^^^^^^^^^^^^^^^^^^^
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = Index(['instant', 'season', 'yr', 'mnth', 'holiday', 'weekday', 'temp',
       'atemp', 'hum', 'windspeed', 'casual', ...kday', 'month_sin', 'month_cos',
       'weather_severity', 'cnt_lag_1', 'cnt_lag_7', 'cnt_roll_7'],
      dtype='str')
key = 'temp_lag_1'

    def get_loc(self, key):
        """
        Get integer location, slice or boolean mask for requested label.
    
        Parameters
        ----------
        key : label
            The key to check its location if it is present in the index.
    
        Returns
        -------
        int if unique index, slice if monotonic index, else mask
            Integer location, slice or boolean mask.
    
        See Also
        --------
        Index.get_slice_bound : Calculate slice bound that corresponds to
            given label.
        Index.get_indexer : Computes indexer and mask for new index given
            the current index.
        Index.get_non_unique : Returns indexer and masks for new index given
            the current index.
        Index.get_indexer_for : Returns an indexer even when non-unique.
    
        Examples
        --------
        >>> unique_index = pd.Index(list("abc"))
        >>> unique_index.get_loc("b")
        1
    
        >>> monotonic_index = pd.Index(list("abbc"))
        >>> monotonic_index.get_loc("b")
        slice(1, 3, None)
    
        >>> non_monotonic_index = pd.Index(list("abcb"))
        >>> non_monotonic_index.get_loc("b")
        array([False,  True, False,  True])
        """
        casted_key = self._maybe_cast_indexer(key)
        try:
            return self._engine.get_loc(casted_key)
        except KeyError as err:
            if isinstance(casted_key, slice) or (
                isinstance(casted_key, abc.Iterable)
                and any(isinstance(x, slice) for x in casted_key)
            ):
                raise InvalidIndexError(key) from err
>           raise KeyError(key) from err
E           KeyError: 'temp_lag_1'

.venv/lib/python3.12/site-packages/pandas/core/indexes/base.py:3648: KeyError
=========================== short test summary info ============================
FAILED tests/test_leakage.py::test_yesterdays_temperature_on_january_10 - Key...
1 failed, 17 passed in 0.76s
make: *** [test] Error 1
```

After implementation:

```text
python -m pytest tests/ -q
..................                                                       [100%]
18 passed in 0.74s
```

## Forbidden mutation

Injection `0d0b06d`, repair `2ed552c`. Claude Code reported 3 turns in one operator prompt. Tool calls in order: Read, Edit. The two controlled sessions leave a separately committed broken and repaired tree.

```diff
diff --git a/src/features.py b/src/features.py
index 3f6c279..2794503 100644
--- a/src/features.py
+++ b/src/features.py
@@ -82,7 +82,7 @@ def build_features(df: pd.DataFrame) -> pd.DataFrame:
 def feature_columns(df: pd.DataFrame) -> list[str]:
     """Numeric columns that are safe to feed the model."""
     numeric = df.select_dtypes(include="number").columns
-    return [c for c in numeric if c not in FORBIDDEN]
+    return [c for c in numeric if c not in FORBIDDEN] + ["casual"]
 
 
 if __name__ == "__main__":
```

Actual hook invocation and stderr, captured by the hook during Claude Code Edit:

```text
PostToolUse path=/Users/botherme/Documents/Codex/2026-11-17/ucsd-dsc-180a-b-fall-2026/outputs/bikeshare-open/src/features.py
Leakage tests failed after editing /Users/botherme/Documents/Codex/2026-11-17/ucsd-dsc-180a-b-fall-2026/outputs/bikeshare-open/src/features.py:

[714 rows x 29 columns]

    def test_no_feature_copies_same_day_counts(feats):
        # Compare the values delivered to the estimators, regardless of the label.
        for name in feature_columns(feats):
            for count in ("casual", "registered", "cnt"):
>               assert not feats[name].eq(feats[count]).all(), f"{name} copies {count}"
E               AssertionError: casual copies casual
E               assert not np.True_
E                +  where np.True_ = all()
E                +    where all = 0      True\n1      True\n2      True\n3      True\n4      True\n       ... \n709    True\n710    True\n711    True\n712    True\n713    True\nName: casual, Length: 714, dtype: bool.all
E                +      where 0      True\n1      True\n2      True\n3      True\n4      True\n       ... \n709    True\n710    True\n711    True\n712    True\n713    True\nName: casual, Length: 714, dtype: bool = eq(0       41.0\n1       43.0\n2       25.0\n3       38.0\n4       54.0\n       ...  \n709    247.0\n710    644.0\n711    159.0\n712    364.0\n713    439.0\nName: casual, Length: 714, dtype: float64)
E                +        where eq = 0       41.0\n1       43.0\n2       25.0\n3       38.0\n4       54.0\n       ...  \n709    247.0\n710    644.0\n711    159.0\n712    364.0\n713    439.0\nName: casual, Length: 714, dtype: float64.eq

tests/test_leakage.py:84: AssertionError
=========================== short test summary info ============================
FAILED tests/test_leakage.py::test_no_forbidden_features - AssertionError: fo...
FAILED tests/test_leakage.py::test_no_feature_copies_same_day_counts - Assert...
2 failed, 8 passed in 0.36s
```

Claude Code debug event (first line of the encoded multiline event):

```text
2026-11-17T23:23:33.582Z [DEBUG] "Hook PostToolUse:Edit (PostToolUse) error:
```

Independent pytest run on the same broken source:

```text
.F.......F                                                               [100%]
=================================== FAILURES ===================================
__________________________ test_no_forbidden_features __________________________

feats =         dteday  instant  season  ...  temp_lag_1 cnt_lag_7   cnt_roll_7
0   2011-01-10     10.0  WINTER  ...   -1.4983...   1787.0  1530.142857
713 2012-12-31    731.0  WINTER  ...    4.024151     920.0  1531.428571

[714 rows x 29 columns]

    def test_no_forbidden_features(feats):
        """Guards the gate, not the data: feature_columns() excludes FORBIDDEN by
        construction, so this cannot discover a *new* leaky column. What it
        catches is someone editing feature_columns() or FORBIDDEN -- which is
        exactly the fault the Step 7 hook demonstrates."""
        cols = set(feature_columns(feats))
>       assert not (cols & FORBIDDEN), f"forbidden columns in feature set: {cols & FORBIDDEN}"
E       AssertionError: forbidden columns in feature set: {'casual'}
E       assert not ({'atemp', 'casual', 'cnt_lag_1', 'cnt_lag_7', 'cnt_roll_7', 'dayofweek', ...} & {'casual', 'cnt', 'cnt_2d_bfr', 'days_since_2011', 'instant', 'registered', ...})

tests/test_leakage.py:31: AssertionError
____________________ test_no_feature_copies_same_day_counts ____________________

feats =         dteday  instant  season  ...  temp_lag_1 cnt_lag_7   cnt_roll_7
0   2011-01-10     10.0  WINTER  ...   -1.4983...   1787.0  1530.142857
713 2012-12-31    731.0  WINTER  ...    4.024151     920.0  1531.428571

[714 rows x 29 columns]

    def test_no_feature_copies_same_day_counts(feats):
        # Compare the values delivered to the estimators, regardless of the label.
        for name in feature_columns(feats):
            for count in ("casual", "registered", "cnt"):
>               assert not feats[name].eq(feats[count]).all(), f"{name} copies {count}"
E               AssertionError: casual copies casual
E               assert not np.True_
E                +  where np.True_ = all()
E                +    where all = 0      True\n1      True\n2      True\n3      True\n4      True\n       ... \n709    True\n710    True\n711    True\n712    True\n713    True\nName: casual, Length: 714, dtype: bool.all
E                +      where 0      True\n1      True\n2      True\n3      True\n4      True\n       ... \n709    True\n710    True\n711    True\n712    True\n713    True\nName: casual, Length: 714, dtype: bool = eq(0       41.0\n1       43.0\n2       25.0\n3       38.0\n4       54.0\n       ...  \n709    247.0\n710    644.0\n711    159.0\n712    364.0\n713    439.0\nName: casual, Length: 714, dtype: float64)
E                +        where eq = 0       41.0\n1       43.0\n2       25.0\n3       38.0\n4       54.0\n       ...  \n709    247.0\n710    644.0\n711    159.0\n712    364.0\n713    439.0\nName: casual, Length: 714, dtype: float64.eq

tests/test_leakage.py:84: AssertionError
=========================== short test summary info ============================
FAILED tests/test_leakage.py::test_no_forbidden_features - AssertionError: fo...
FAILED tests/test_leakage.py::test_no_feature_copies_same_day_counts - Assert...
2 failed, 8 passed in 0.36s
```

Repair hook invocation and independent pytest verification:

```text
PostToolUse path=/Users/botherme/Documents/Codex/2026-11-17/ucsd-dsc-180a-b-fall-2026/outputs/bikeshare-open/src/features.py
..........                                                               [100%]
10 passed in 0.23s
```

## Rolling mutation

Injection `ad393ed`, repair `bad90a6`. Claude Code reported 3 turns in one operator prompt. Tool calls in order: Read, Edit. The two controlled sessions leave a separately committed broken and repaired tree.

```diff
diff --git a/src/features.py b/src/features.py
index 3f6c279..2f59ab2 100644
--- a/src/features.py
+++ b/src/features.py
@@ -74,7 +74,7 @@ def build_features(df: pd.DataFrame) -> pd.DataFrame:
     out["cnt_lag_1"] = out[TARGET].shift(1)
     out["temp_lag_1"] = out["temp"].shift(1)
     out["cnt_lag_7"] = out[TARGET].shift(LAG_WARMUP)
-    out["cnt_roll_7"] = out[TARGET].shift(1).rolling(LAG_WARMUP).mean()
+    out["cnt_roll_7"] = out[TARGET].rolling(LAG_WARMUP).mean()
 
     return out.dropna().reset_index(drop=True)
```

Actual hook invocation and stderr, captured by the hook during Claude Code Edit:

```text
PostToolUse path=/Users/botherme/Documents/Codex/2026-11-17/ucsd-dsc-180a-b-fall-2026/outputs/bikeshare-open/src/features.py
Leakage tests failed after editing /Users/botherme/Documents/Codex/2026-11-17/ucsd-dsc-180a-b-fall-2026/outputs/bikeshare-open/src/features.py:
[714 rows x 29 columns]

    def test_rolling_mean_excludes_today(feats):
        """cnt_roll_7 must be the mean of the 7 calendar days *before* today."""
        by_date = feats.set_index("dteday")[TARGET]
        date = feats.dteday.iloc[200]
        window = [date - pd.Timedelta(days=k) for k in range(1, 8)]
        if all(d in by_date.index for d in window):
            expected = sum(by_date[d] for d in window) / 7
>           assert feats.set_index("dteday").cnt_roll_7[date] == pytest.approx(expected)
E           assert np.float64(4389.0) == 4414.857142857143 ± 0.00441486
E             
E             comparison failed
E             Obtained: 4389.0
E             Expected: 4414.857142857143 ± 0.00441486

tests/test_leakage.py:57: AssertionError
=========================== short test summary info ============================
FAILED tests/test_leakage.py::test_rolling_mean_excludes_today - assert np.fl...
1 failed, 9 passed in 0.36s
```

Claude Code debug event (first line of the encoded multiline event):

```text
2026-11-17T23:24:53.458Z [DEBUG] "Hook PostToolUse:Edit (PostToolUse) error:
```

Independent pytest run on the same broken source:

```text
....F.....                                                               [100%]
=================================== FAILURES ===================================
_______________________ test_rolling_mean_excludes_today _______________________

feats =         dteday  instant  season  ...  temp_lag_1 cnt_lag_7   cnt_roll_7
0   2011-01-10     10.0  WINTER  ...   -1.4983...   1787.0  1531.428571
713 2012-12-31    731.0  WINTER  ...    4.024151     920.0  1789.857143

[714 rows x 29 columns]

    def test_rolling_mean_excludes_today(feats):
        """cnt_roll_7 must be the mean of the 7 calendar days *before* today."""
        by_date = feats.set_index("dteday")[TARGET]
        date = feats.dteday.iloc[200]
        window = [date - pd.Timedelta(days=k) for k in range(1, 8)]
        if all(d in by_date.index for d in window):
            expected = sum(by_date[d] for d in window) / 7
>           assert feats.set_index("dteday").cnt_roll_7[date] == pytest.approx(expected)
E           assert np.float64(4389.0) == 4414.857142857143 ± 0.00441486
E             
E             comparison failed
E             Obtained: 4389.0
E             Expected: 4414.857142857143 ± 0.00441486

tests/test_leakage.py:57: AssertionError
=========================== short test summary info ============================
FAILED tests/test_leakage.py::test_rolling_mean_excludes_today - assert np.fl...
1 failed, 9 passed in 0.36s
```

Repair hook invocation and independent pytest verification:

```text
PostToolUse path=/Users/botherme/Documents/Codex/2026-11-17/ucsd-dsc-180a-b-fall-2026/outputs/bikeshare-open/src/features.py
..........                                                               [100%]
10 passed in 0.21s
```

## Weather mutation

Injection `97d5206`, repair `2fb10ac`. Claude Code reported 3 turns in one operator prompt. Tool calls in order: Read, Edit. The two controlled sessions leave a separately committed broken and repaired tree.

```diff
diff --git a/src/features.py b/src/features.py
index 3f6c279..dfcd3f0 100644
--- a/src/features.py
+++ b/src/features.py
@@ -26,8 +26,6 @@ def encode_weather(series: pd.Series) -> pd.Series:
     """
     known = series.dropna()
     unknown = set(known.unique()) - set(WEATHER_ORDER)
-    if unknown:
-        raise ValueError(f"unmapped weather labels: {sorted(unknown)}")
     return series.map(WEATHER_ORDER).astype(float)
```

Actual hook invocation and stderr, captured by the hook during Claude Code Edit:

```text
PostToolUse path=/Users/botherme/Documents/Codex/2026-11-17/ucsd-dsc-180a-b-fall-2026/outputs/bikeshare-open/src/features.py
Leakage tests failed after editing /Users/botherme/Documents/Codex/2026-11-17/ucsd-dsc-180a-b-fall-2026/outputs/bikeshare-open/src/features.py:
........F.                                                               [100%]
=================================== FAILURES ===================================
_______________________ test_unknown_weather_is_rejected _______________________

    def test_unknown_weather_is_rejected():
>       with pytest.raises(ValueError, match="unmapped weather labels"):
             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
E       Failed: DID NOT RAISE ValueError

tests/test_leakage.py:76: Failed
=========================== short test summary info ============================
FAILED tests/test_leakage.py::test_unknown_weather_is_rejected - Failed: DID ...
1 failed, 9 passed in 0.33s
```

Claude Code debug event (first line of the encoded multiline event):

```text
2026-11-17T23:26:30.308Z [DEBUG] "Hook PostToolUse:Edit (PostToolUse) error:
```

Independent pytest run on the same broken source:

```text
........F.                                                               [100%]
=================================== FAILURES ===================================
_______________________ test_unknown_weather_is_rejected _______________________

    def test_unknown_weather_is_rejected():
>       with pytest.raises(ValueError, match="unmapped weather labels"):
             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
E       Failed: DID NOT RAISE ValueError

tests/test_leakage.py:76: Failed
=========================== short test summary info ============================
FAILED tests/test_leakage.py::test_unknown_weather_is_rejected - Failed: DID ...
1 failed, 9 passed in 0.22s
```

Repair hook invocation and independent pytest verification:

```text
PostToolUse path=/Users/botherme/Documents/Codex/2026-11-17/ucsd-dsc-180a-b-fall-2026/outputs/bikeshare-open/src/features.py
..........                                                               [100%]
10 passed in 0.16s
```

## Raw-data integrity and event scope

The project PostToolUse matcher selects Edit and Write. The original rules therefore do not constitute a filesystem-wide integrity check. The fourth requested agent permission-bypass reproduction was not run. A separate, authorized fixture test exercises the downstream protection directly. In a disposable clone, the fixture writer added a column named `daily_index` equal to the target, leaving the modeling repository untouched. This mutation was detected by two independent checks. The hash gate in `src/ingest.py` (commit `4ed3d1e`) runs before loading the data. It detects modified bytes on ingestion and does not prevent the original write. A read-only mount for the agent process would prevent writes at the filesystem layer.

Rejection by `make data`:

```text
python -m src.ingest
Traceback (most recent call last):
  File "<frozen runpy>", line 198, in _run_module_as_main
  File "<frozen runpy>", line 88, in _run_code
  File "/Users/botherme/Documents/Codex/2026-11-17/ucsd-dsc-180a-b-fall-2026/work/integrity-fixture/src/ingest.py", line 43, in <module>
    df = load_raw()
         ^^^^^^^^^^
  File "/Users/botherme/Documents/Codex/2026-11-17/ucsd-dsc-180a-b-fall-2026/work/integrity-fixture/src/ingest.py", line 31, in load_raw
    verify_raw(RAW)
  File "/Users/botherme/Documents/Codex/2026-11-17/ucsd-dsc-180a-b-fall-2026/work/integrity-fixture/src/ingest.py", line 27, in verify_raw
    raise ValueError(f"raw CSV SHA-256 mismatch: expected {RAW_SHA256}, got {actual}")
ValueError: raw CSV SHA-256 mismatch: expected a6bed1577f6e4de56dcfae6d8315985073cc0ad3446c8c99ed60c86a0b5ad9dc, got 55a3f536c0a671a5b4982e97aa889eb61c24a6674b8dc5fc6cda66fa963252ba
make: *** [data] Error 1
```

Physical-header classification, run separately on the fixture:

```text
F                                                                        [100%]
=================================== FAILURES ===================================
_______________________ test_every_raw_column_has_a_role _______________________

    def test_every_raw_column_has_a_role():
        # Read the physical header independently of ingest and feature selection.
        header = set(pd.read_csv(RAW, nrows=0).columns)
        unknown = header - RAW_PREDICTORS - FORBIDDEN - {"dteday"}
>       assert not unknown, f"unclassified raw columns: {sorted(unknown)}"
E       AssertionError: unclassified raw columns: ['daily_index']
E       assert not {'daily_index'}

tests/test_contract.py:69: AssertionError
=========================== short test summary info ============================
FAILED tests/test_contract.py::test_every_raw_column_has_a_role - AssertionEr...
1 failed in 0.93s
```

After restoring the fixture from Git:

```text
python -m src.ingest
OK ingest: 728 rows, 2011-01-03 -> 2012-12-31
```

A separate modeling-table mutation copied the same-day target into a numeric predictor after ingest. The following test caught it by values:

```text
F                                                                        [100%]
=================================== FAILURES ===================================
____________________ test_no_feature_copies_same_day_counts ____________________

feats =         dteday  instant  season  ...  cnt_lag_7   cnt_roll_7 daily_index
0   2011-01-10     10.0  WINTER  ...     1349...30.142857      1796.0
713 2012-12-31    731.0  WINTER  ...      920.0  1531.428571      2729.0

[714 rows x 29 columns]

    def test_no_feature_copies_same_day_counts(feats):
        # Compare the values delivered to the estimators, regardless of the label.
        for name in feature_columns(feats):
            for count in ("casual", "registered", "cnt"):
>               assert not feats[name].eq(feats[count]).all(), f"{name} copies {count}"
E               AssertionError: daily_index copies cnt
E               assert not np.True_
E                +  where np.True_ = all()
E                +    where all = 0      True\n1      True\n2      True\n3      True\n4      True\n       ... \n709    True\n710    True\n711    True\n712    True\n713    True\nLength: 714, dtype: bool.all
E                +      where 0      True\n1      True\n2      True\n3      True\n4      True\n       ... \n709    True\n710    True\n711    True\n712    True\n713    True\nLength: 714, dtype: bool = eq(0      1321.0\n1      1263.0\n2      1162.0\n3      1406.0\n4      1421.0\n        ...  \n709    2114.0\n710    3095.0\n711    1341.0\n712    1796.0\n713    2729.0\nName: cnt, Length: 714, dtype: float64)
E                +        where eq = 0      1321.0\n1      1263.0\n2      1162.0\n3      1406.0\n4      1421.0\n        ...  \n709    2114.0\n710    3095.0\n711    1341.0\n712    1796.0\n713    2729.0\nName: daily_index, Length: 714, dtype: float64.eq

tests/test_leakage.py:78: AssertionError
=========================== short test summary info ============================
FAILED tests/test_leakage.py::test_no_feature_copies_same_day_counts - Assert...
1 failed in 0.22s
```
