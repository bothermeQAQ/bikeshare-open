.PHONY: all data features train test clean model check-model

# --- The pipeline ----------------------------------------------------------
all: data features train

data:
	python -m src.ingest

features:
	python -m src.features

train:
	python -m src.train

test:
	python -m pytest tests/ -q

clean:
	rm -f data/processed/*.parquet reports/metrics.json reports/*.png

# --- The agent model (open weights, local) ----------------------------------
# Builds `bikeshare-coder`: the base model plus a 64k context window, which
# Claude Code needs and Ollama does not give you by default. Pick a larger
# BASE if your machine has the memory (see README.md).
BASE ?= qwen3.5:9b

model:
	ollama pull $(BASE)
	tmp=$$(mktemp) && trap 'rm -f "$$tmp"' EXIT && \
	sed "s|^FROM .*|FROM $(BASE)|" model/Modelfile > "$$tmp" && \
	ollama create bikeshare-coder -f "$$tmp"

check-model:
	bash model/check.sh

.PHONY: validate
validate: features
	python -m src.train --validation-only

.PHONY: validate-ridge validate-hgb
validate-ridge validate-hgb: features
	python -m src.train --validation-summary $(@:validate-%=%)

.PHONY: check-raw-integrity
check-raw-integrity:
	bash scripts/check_raw_integrity.sh
