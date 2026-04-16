/// Forge benchmark fixture — Rust stack (Criterion).
///
/// Fill in `target_operation()` with the hot path you want to measure.
/// Run via: cargo bench
///
/// Cargo.toml setup required:
///   [dev-dependencies]
///   criterion = { version = "0.5", features = ["html_reports"] }
///
///   [[bench]]
///   name = "forge_bench"
///   harness = false
use criterion::{black_box, criterion_group, criterion_main, Criterion};

fn target_operation(n: u64) -> u64 {
    // TODO: replace with your actual operation.
    // Keep it representative of a typical hot path in your project.
    // Use black_box() to prevent the compiler from optimizing it away.
    (0..n).fold(0u64, |acc, x| acc.wrapping_add(x))
}

fn bench_target(c: &mut Criterion) {
    c.bench_function("forge_bench", |b| {
        b.iter(|| target_operation(black_box(10_000)))
    });
}

criterion_group!(benches, bench_target);
criterion_main!(benches);
