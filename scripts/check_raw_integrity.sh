#!/usr/bin/env bash
# Exercise the real ingestion gate against a test-owned copy of the repository.
set -euo pipefail
root=$(git rev-parse --show-toplevel)
scratch=$(mktemp -d)
trap 'rm -r -- "$scratch"' EXIT
mkdir "$scratch/fixture"
git -C "$root" archive HEAD -- Makefile src data/raw/bike_daily.csv |
  tar -x -C "$scratch/fixture"
cd "$scratch/fixture"

# A trailing newline changes the file digest without changing an observation.
python - <<'PY'
from pathlib import Path
import pandas as pd
from src.config import RAW, RAW_SHA256
from hashlib import sha256
assert sha256(RAW.read_bytes()).hexdigest() == RAW_SHA256
sample = Path("copy-source.csv")
sample.write_bytes(RAW.read_bytes() + b"\n")
pd.testing.assert_frame_equal(pd.read_csv(RAW), pd.read_csv(sample))
print(f"Before copy: {RAW_SHA256} ({len(pd.read_csv(sample))} unchanged rows)")
PY

cp copy-source.csv data/raw/bike_daily.csv
python - <<'PY'
from hashlib import sha256
from src.config import RAW, RAW_SHA256
actual = sha256(RAW.read_bytes()).hexdigest()
assert actual != RAW_SHA256
print(f"After Bash cp: {actual}")
PY
if make data > make-data.log 2>&1; then
  echo "FAIL: ingestion accepted changed bytes" >&2
  exit 1
else
  status=$?
fi
cat make-data.log
grep -Fq 'raw CSV SHA-256 mismatch' make-data.log
echo "make data exit status: $status"

git -C "$root" show HEAD:data/raw/bike_daily.csv > data/raw/bike_daily.csv
make data
python - <<'PY'
from src.config import RAW, RAW_SHA256
from src.ingest import verify_raw
verify_raw(RAW)
print(f"Restored fixture: {RAW_SHA256}")
PY
