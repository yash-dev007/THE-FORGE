#!/usr/bin/env bash
# Minimal Forge evaluator: fixed neutral scores. Customize after adoption.
set -euo pipefail

PERF_SCORE=5.0
QUAL_SCORE=5.0
TEST_SCORE=5.0
DEBT_SCORE=5.0
SCORE=5.0

echo "PERF_SCORE: ${PERF_SCORE}"
echo "QUAL_SCORE: ${QUAL_SCORE}"
echo "TEST_SCORE: ${TEST_SCORE}"
echo "DEBT_SCORE: ${DEBT_SCORE}"
echo "SCORE: ${SCORE}"
echo "FORGE_EVAL_WARN: minimal noop — replace with stack template (python/node/go) before real cycles" >&2
exit 0
