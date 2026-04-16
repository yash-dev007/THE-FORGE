"""
Forge benchmark fixture — Python stack.
Run via: pytest benchmark.py --benchmark-only

Fill in the `target_operation()` function with the code path you want to measure.
The PERF_SCORE in EVAL.sh will use the median runtime of this fixture.

Install: pip install pytest-benchmark
"""
import pytest


def target_operation():
    """
    Replace this with the operation you want to benchmark.
    Example: parse a file, run a calculation, call a local function.
    Keep it representative of a typical request/operation in your project.
    """
    # TODO: replace with your actual operation
    total = sum(range(10_000))
    return total


def test_benchmark_target(benchmark):
    """Benchmark fixture — PERF_SCORE is derived from this."""
    result = benchmark(target_operation)
    # Basic sanity check — adjust as needed
    assert result is not None
