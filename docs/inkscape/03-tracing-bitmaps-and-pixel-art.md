# Inkscape — tracing bitmaps and pixel art

Distilled from **Tracing bitmaps** and **Tracing Pixel Art** tutorials. Menu: **Path → Trace Bitmap** (Shift+Alt+B).

## Purpose

Tracing produces **editable curves**, not a perfect duplicate. Use output as a starting point; simplify and clean up manually.

## Standard trace (Potrace) — filters

Apply to selected **embedded/imported** bitmap. Preview filters before OK.

| Filter | Behavior |
|--------|----------|
| **Brightness cutoff** | RGB sum vs threshold 0–1; higher = fewer white pixels = darker intermediate |
| **Edge detection** | Canny edges; threshold adjusts edge thickness |
| **Color quantization** | Edges where **colors** change; N colors → even/odd index → B/W |

Try all three; image-dependent which works best. More black pixels → more nodes, larger SVG, slower.

## After trace

- **Path → Simplify (Ctrl+L)** on result — often essential (trace can add huge node counts).
- Trace output is usually grouped — **Ctrl+Shift+G** to ungroup for editing.
- For laser/CNC: prefer **centerline** or simplified paths; filled silhouettes vs strokes depends on job.

## Autotrace and centerline

- **Autotrace:** alternate algorithm, extra parameters, slower, different aesthetic.
- **Centerline tracing (autotrace):** for **line drawings** — strokes you can edit, not filled regions.

## Pixel art tab (libdepixelize / Kopf-Lischinski)

For low-res pixel art (game sprites, Liberated Pixel Cup style). **Not** ideal for photos — use standard trace tab.

- **Alpha channel ignored** by algorithm (usually fine; report bad cases to libdepixelize if alpha causes issues).
- **Default output:** smooth B-splines (best general choice).
- **Voronoi output:** reshaped cells, straight lines only — good for inspecting heuristics.
- **B-splines:** Voronoi → quadratic Béziers; merges at T-junctions (heuristics not user-tunable at this stage).
- Future: "optimize curves" anti-staircasing (experimental in libdepixelize).

### Heuristics (2×2 diagonal conflicts)

Tune in **Heuristics** section; preview with **Voronoi** output:

| Heuristic | Role |
|-----------|------|
| **Curves** | Keep long curves connected; "fair" voting |
| **Islands** | Avoid isolated pixel islands |
| **Sparse pixels** | Favor foreground color connections; window size + multiplier (author often uses 0.25 multiplier) |

Set multiplier to **0** to disable; **negative** inverts behavior (artistic glitch effects).

## Workflow for MeerK40t / laser users

1. Import PNG/SVG art at correct physical size (mm) in document properties.
2. Trace if raster; simplify; Object to Path if needed.
3. Union/clean duplicates; set stroke vs fill per driver expectations (GRBL often wants hairline vectors or filled regions depending on workflow).
4. Export SVG or save native SVG for MeerK40t import.

See also Peppertop FCM #79–81, #170–171 in [05-peppertop-fcm-index.md](05-peppertop-fcm-index.md).
