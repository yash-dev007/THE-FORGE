#!/usr/bin/env python3
"""
forge-chart.py — THE FORGE v4 score visualization
Reads PROJECT_LOG.md → outputs forge-chart.html (zero dependencies, stdlib only).
Falls back to plotly if installed for richer charts.

Usage:
    python forge-chart.py                       # reads PROJECT_LOG.md in cwd
    python forge-chart.py --log path/to/log.md
    python forge-chart.py --output forge-chart.html
"""
import argparse
import re
import sys
import json
import html
from pathlib import Path
from datetime import datetime

# ── Argument parsing ─────────────────────────────────────────────────────────
parser = argparse.ArgumentParser(description="Forge score chart generator")
parser.add_argument("--log", default="PROJECT_LOG.md", help="Path to PROJECT_LOG.md")
parser.add_argument("--output", default="forge-chart.html", help="Output HTML file")
args = parser.parse_args()

log_path = Path(args.log)
if not log_path.exists():
    print(f"Error: {log_path} not found. Run from your adopted repo root.", file=sys.stderr)
    sys.exit(1)

# ── Parse PROJECT_LOG.md ─────────────────────────────────────────────────────
content = log_path.read_text(encoding="utf-8")

cycles: list[dict] = []
# Match cycle headings: "## Cycle N — YYYY-MM-DD — Type"
cycle_blocks = re.split(r"(?=^## Cycle \d+)", content, flags=re.MULTILINE)

for block in cycle_blocks:
    m = re.match(r"## Cycle (\d+)\s*—\s*(\d{4}-\d{2}-\d{2})\s*—\s*(\S+)", block)
    if not m:
        continue

    cycle_num = int(m.group(1))
    date_str  = m.group(2)
    hypo_type = m.group(3)

    # Extract scores row: "COMPOSITE: X→Y" or individual sub-scores
    scores_m = re.search(
        r"COMPOSITE:\s*([\d.]+)\s*→\s*([\d.]+)", block
    )
    perf_m = re.search(r"PERF:\s*([\d.]+)\s*→\s*([\d.]+)", block)
    qual_m = re.search(r"QUAL:\s*([\d.]+)\s*→\s*([\d.]+)", block)
    test_m = re.search(r"TEST:\s*([\d.]+)\s*→\s*([\d.]+)", block)
    debt_m = re.search(r"DEBT:\s*([\d.]+)\s*→\s*([\d.]+)", block)
    decision_m = re.search(r"\|\s*Decision\s*\|\s*(COMMIT|REVERT|HOLD|ANOMALY)", block)

    if not scores_m:
        continue

    cycles.append({
        "cycle":    cycle_num,
        "date":     date_str,
        "type":     hypo_type,
        "baseline": float(scores_m.group(1)),
        "score":    float(scores_m.group(2)),
        "delta":    round(float(scores_m.group(2)) - float(scores_m.group(1)), 2),
        "perf":     float(perf_m.group(2)) if perf_m else None,
        "qual":     float(qual_m.group(2)) if qual_m else None,
        "test":     float(test_m.group(2)) if test_m else None,
        "debt":     float(debt_m.group(2)) if debt_m else None,
        "decision": decision_m.group(1) if decision_m else "?",
    })

if not cycles:
    print("No cycle data found in PROJECT_LOG.md — run at least one cycle first.")
    sys.exit(0)

cycles.sort(key=lambda c: c["cycle"])

# ── Try plotly for rich charts ────────────────────────────────────────────────
plotly_available = False
try:
    import plotly.graph_objects as go
    from plotly.subplots import make_subplots
    plotly_available = True
except ImportError:
    pass

if plotly_available:
    # Rich interactive chart via plotly
    fig = make_subplots(
        rows=2, cols=1,
        subplot_titles=("Composite SCORE over Cycles", "Sub-scores over Cycles"),
        vertical_spacing=0.12,
    )

    x = [c["cycle"] for c in cycles]
    scores  = [c["score"]    for c in cycles]
    baselines = [c["baseline"] for c in cycles]

    # Row 1: composite score + baseline
    fig.add_trace(go.Scatter(x=x, y=scores, name="Score", mode="lines+markers",
                             line=dict(color="#4CAF50", width=2)), row=1, col=1)
    fig.add_trace(go.Scatter(x=x, y=baselines, name="Baseline", mode="lines",
                             line=dict(color="#9E9E9E", dash="dot", width=1)), row=1, col=1)

    # Row 2: sub-scores
    for key, color, name in [
        ("perf", "#2196F3", "PERF"),
        ("qual", "#FF9800", "QUAL"),
        ("test", "#4CAF50", "TEST"),
        ("debt", "#9C27B0", "DEBT"),
    ]:
        vals = [c[key] for c in cycles]
        if any(v is not None for v in vals):
            fig.add_trace(go.Scatter(x=x, y=vals, name=name, mode="lines+markers",
                                     line=dict(color=color, width=1.5)), row=2, col=1)

    fig.update_layout(
        title="THE FORGE — Score History",
        height=700,
        font=dict(family="monospace"),
        template="plotly_dark",
    )
    fig.write_html(args.output, include_plotlyjs="cdn")
    print(f"Chart written: {args.output} (plotly)")

else:
    # Pure stdlib: inline SVG chart
    def _scale(val: float, lo: float = 0.0, hi: float = 10.0,
               out_lo: float = 0.0, out_hi: float = 300.0) -> float:
        if hi == lo:
            return out_lo
        return out_lo + (val - lo) / (hi - lo) * (out_hi - out_lo)

    # Build SVG path for scores
    n = len(cycles)
    W, H = 700, 200
    margin = {"left": 40, "right": 20, "top": 20, "bottom": 30}
    plot_w = W - margin["left"] - margin["right"]
    plot_h = H - margin["top"] - margin["bottom"]

    def _x(i: int) -> float:
        return margin["left"] + (i / max(n - 1, 1)) * plot_w

    def _y(v: float) -> float:
        return margin["top"] + plot_h - _scale(v, 0, 10, 0, plot_h)

    def _path(values: list, color: str, label: str) -> str:
        pts = [(f"{_x(i):.1f}", f"{_y(v):.1f}") for i, v in enumerate(values) if v is not None]
        if len(pts) < 2:
            return ""
        d = "M " + " L ".join(f"{x},{y}" for x, y in pts)
        return f'<path d="{d}" stroke="{color}" stroke-width="2" fill="none" />'

    score_path  = _path([c["score"] for c in cycles], "#4CAF50", "Score")
    perf_path   = _path([c["perf"]  for c in cycles], "#2196F3", "PERF")
    qual_path   = _path([c["qual"]  for c in cycles], "#FF9800", "QUAL")
    test_path   = _path([c["test"]  for c in cycles], "#66BB6A", "TEST")
    debt_path   = _path([c["debt"]  for c in cycles], "#9C27B0", "DEBT")

    # Decision badge colors
    BADGE_COLORS = {
        "COMMIT":  ("#1B5E20", "#A5D6A7"),
        "REVERT":  ("#B71C1C", "#EF9A9A"),
        "HOLD":    ("#E65100", "#FFCC80"),
        "ANOMALY": ("#4A148C", "#CE93D8"),
        "?":       ("#333",    "#999"),
    }

    last10 = cycles[-10:]
    table_rows = ""
    for c in last10:
        bg, fg = BADGE_COLORS.get(c["decision"], ("#333", "#999"))
        delta_str = f"+{c['delta']}" if c["delta"] >= 0 else str(c["delta"])
        table_rows += f"""
        <tr>
          <td>{c['cycle']}</td>
          <td>{c['date']}</td>
          <td>{c['type']}</td>
          <td>{c['baseline']:.2f}</td>
          <td>{c['score']:.2f}</td>
          <td style="color:{'#4CAF50' if c['delta']>=0 else '#F44336'}">{delta_str}</td>
          <td><span style="background:{bg};color:{fg};padding:2px 6px;border-radius:4px;font-size:11px">{c['decision']}</span></td>
        </tr>"""

    generated = datetime.now().strftime("%Y-%m-%d %H:%M")
    html_content = f"""<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>THE FORGE — Score Chart</title>
<style>
  body {{ font-family: monospace; background: #1a1a2e; color: #e0e0e0; margin: 0; padding: 24px; }}
  h1 {{ color: #64B5F6; font-size: 20px; margin-bottom: 4px; }}
  .subtitle {{ color: #78909C; font-size: 12px; margin-bottom: 24px; }}
  .chart-box {{ background: #16213e; border-radius: 8px; padding: 16px; margin-bottom: 24px; }}
  h2 {{ color: #90CAF9; font-size: 14px; margin: 0 0 8px 0; }}
  svg text {{ font-family: monospace; }}
  table {{ border-collapse: collapse; width: 100%; font-size: 13px; }}
  th {{ background: #0f3460; color: #90CAF9; padding: 8px; text-align: left; }}
  td {{ padding: 6px 8px; border-bottom: 1px solid #1a1a2e; }}
  tr:hover td {{ background: #1a2a4a; }}
  .legend {{ display: flex; gap: 16px; margin-bottom: 8px; font-size: 12px; }}
  .legend-item {{ display: flex; align-items: center; gap: 4px; }}
  .legend-dot {{ width: 12px; height: 3px; border-radius: 2px; }}
</style>
</head>
<body>
<h1>THE FORGE — Score History</h1>
<div class="subtitle">Generated: {generated} | Cycles: {n} | Log: {html.escape(args.log)}</div>

<div class="chart-box">
  <h2>Composite SCORE</h2>
  <div class="legend">
    <span class="legend-item"><span class="legend-dot" style="background:#4CAF50"></span>Score</span>
  </div>
  <svg width="{W}" height="{H}" style="display:block">
    <!-- Y axis -->
    <line x1="{margin['left']}" y1="{margin['top']}" x2="{margin['left']}" y2="{margin['top']+plot_h}" stroke="#555" />
    <!-- Grid lines at 2, 4, 6, 8, 10 -->
    {''.join(f'<line x1="{margin["left"]}" y1="{_y(v):.1f}" x2="{margin["left"]+plot_w}" y2="{_y(v):.1f}" stroke="#333" stroke-dasharray="4" /><text x="{margin["left"]-4}" y="{_y(v)+4:.1f}" fill="#666" font-size="10" text-anchor="end">{v}</text>' for v in [2, 4, 6, 8, 10])}
    {score_path}
    <!-- Dots -->
    {''.join(f'<circle cx="{_x(i):.1f}" cy="{_y(c["score"]):.1f}" r="3" fill="#4CAF50" />' for i, c in enumerate(cycles))}
    <!-- X axis labels -->
    {''.join(f'<text x="{_x(i):.1f}" y="{margin["top"]+plot_h+16}" fill="#888" font-size="10" text-anchor="middle">{c["cycle"]}</text>' for i, c in enumerate(cycles) if i % max(1, n//10) == 0)}
  </svg>
</div>

<div class="chart-box">
  <h2>Sub-scores</h2>
  <div class="legend">
    <span class="legend-item"><span class="legend-dot" style="background:#2196F3"></span>PERF</span>
    <span class="legend-item"><span class="legend-dot" style="background:#FF9800"></span>QUAL</span>
    <span class="legend-item"><span class="legend-dot" style="background:#66BB6A"></span>TEST</span>
    <span class="legend-item"><span class="legend-dot" style="background:#9C27B0"></span>DEBT</span>
  </div>
  <svg width="{W}" height="{H}" style="display:block">
    <line x1="{margin['left']}" y1="{margin['top']}" x2="{margin['left']}" y2="{margin['top']+plot_h}" stroke="#555" />
    {''.join(f'<line x1="{margin["left"]}" y1="{_y(v):.1f}" x2="{margin["left"]+plot_w}" y2="{_y(v):.1f}" stroke="#333" stroke-dasharray="4" /><text x="{margin["left"]-4}" y="{_y(v)+4:.1f}" fill="#666" font-size="10" text-anchor="end">{v}</text>' for v in [2, 4, 6, 8, 10])}
    {perf_path}
    {qual_path}
    {test_path}
    {debt_path}
  </svg>
</div>

<div class="chart-box">
  <h2>Last {len(last10)} cycles</h2>
  <table>
    <thead><tr>
      <th>#</th><th>Date</th><th>Type</th>
      <th>Baseline</th><th>Score</th><th>Δ</th><th>Decision</th>
    </tr></thead>
    <tbody>{table_rows}</tbody>
  </table>
</div>

</body>
</html>
"""
    Path(args.output).write_text(html_content, encoding="utf-8")
    print(f"Chart written: {args.output} (stdlib SVG)")
    print("Tip: install plotly for interactive charts: pip install plotly")

# ── Obsidian embed snippet ────────────────────────────────────────────────────
embed_path = Path(args.output).with_suffix(".embed.md")
rel_html = Path(args.output).name
embed_path.write_text(
    f"## Forge Score Chart\n\n"
    f"> Auto-generated by `python forge-chart.py`\n\n"
    f'<iframe src="{rel_html}" width="100%" height="850" frameborder="0"></iframe>\n',
    encoding="utf-8",
)
print(f"Obsidian embed snippet: {embed_path}")
