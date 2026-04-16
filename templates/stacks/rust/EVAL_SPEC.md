# EVAL_SPEC — Rust starter

Tune commands and weights after adoption. Agents must not edit this file during
hypothesis cycles (write-protected by `CLAUDE.md` Rule 1). Human maintainers may
edit for adoption, stack upgrades, or scorecard redesign only.

## Weights

| Dimension | Weight | Source in `EVAL.sh` |
|-----------|--------|---------------------|
| PERF_SCORE | 0.20 | `cargo bench` (Criterion) or `hyperfine` via `FORGE_BENCH_CMD` |
| QUAL_SCORE | 0.25 | `cargo clippy -- -D warnings` (0 warnings → 9.0; any → 3.0) |
| TEST_SCORE | 0.35 | `cargo test --quiet` |
| DEBT_SCORE | 0.20 | clippy complexity lints (cognitive_complexity, too_many_arguments) |

Composite: `SCORE = 0.20*PERF + 0.25*QUAL + 0.35*TEST + 0.20*DEBT` (rounded to 2 decimals).

## Exit codes

| Code | Meaning |
|------|---------|
| 0 | Harness finished; inspect score lines |
| 1 | `cargo test` failed |
| 2 | Environment error (`cargo` not on PATH) |

## Optional tools

| Tool | Dimension | Setup |
|------|-----------|-------|
| `cargo bench` + Criterion | PERF | Add to `Cargo.toml` (see below) + fill `benches/forge_bench.rs` |
| `hyperfine` | PERF (fallback) | System package; set `FORGE_BENCH_CMD` in `FORGE_IDENTITY.md` |
| `cargo clippy` | QUAL + DEBT | Included with `rustup` — no extra install |

## Criterion setup (PERF_SCORE wiring)

Add to `Cargo.toml`:
```toml
[dev-dependencies]
criterion = { version = "0.5", features = ["html_reports"] }

[[bench]]
name = "forge_bench"
harness = false
```

Then fill in `benches/forge_bench.rs` with your target function.
Run manually: `cargo bench` to verify before adopting.

## DEBT_SCORE interpretation

Clippy complexity warnings (cognitive_complexity, too_many_arguments) each reduce
DEBT_SCORE by 0.5, with a floor of 3.0:

| Complexity warnings | DEBT_SCORE |
|---------------------|------------|
| 0 | 9.0 |
| 5 | 6.5 |
| 10 | 4.0 |
| 14+ | 3.0 (floor) |

To allow higher complexity in legacy code, add `#[allow(clippy::cognitive_complexity)]`
at the function level. Document exceptions in `FORGE_SYSTEM.md` under **Scorecard rationale**.
