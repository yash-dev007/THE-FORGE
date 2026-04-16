/**
 * Forge benchmark fixture — Node stack.
 * Run via: npx vitest bench (requires vitest >=0.34)
 *
 * Fill in targetOperation() with the code path you want to measure.
 * The PERF_SCORE in EVAL.sh will use the ops/sec from this fixture.
 *
 * Install: npm install --save-dev vitest
 */
import { bench, describe } from "vitest";

function targetOperation() {
  // TODO: replace with your actual operation.
  // Example: parse JSON, run a calculation, call a local function.
  let total = 0;
  for (let i = 0; i < 10_000; i++) total += i;
  return total;
}

describe("Forge PERF benchmark", () => {
  bench("target operation", () => {
    targetOperation();
  });
});
