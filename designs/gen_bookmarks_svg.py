#!/usr/bin/env python3
"""Generate 4 zentangle-style bookmark SVGs for MeerK40t: red=cut border, blue=vector engrave.

Design prompts (for AI image tools, tracing, or briefs) — yours, kept here for copy/paste:

1) Highly detailed intricate black line art bookmark, exactly 100mm wide by 50mm tall,
   landscape orientation, complex organic flowing curves and dense layered decorative
   polylines, elegant abstract floral and curvilinear motifs, sophisticated continuous
   line patterns similar to professional laser-cut DXF artwork, high contrast bold black
   lines on clean white background, very intricate and elegant design with smooth bezier
   curves, rich decorative details, precise vector aesthetic, bookmark format with small
   circular hole at the top center for tassel, professional design for laser cutting or
   engraving.

2) Highly detailed intricate floral bookmark, 100mm x 50mm, landscape orientation, dense
   elegant flowing leaves and petals made of smooth continuous black lines, layered organic
   patterns in the style of professional DXF laser cut art, high contrast black vector
   linework on white, sophisticated decorative composition, small hole at top for tassel.

3) Intricate abstract swirly bookmark 100mm wide 50mm tall, dense flowing organic curves
   and layered decorative polylines, black line art only, complex elegant patterns similar
   to high-end DXF vector artwork, bold black lines, white background, small tassel hole at
   top, highly detailed vector style.

NOTE: Those prompts assume landscape 100×50 mm. This generator uses portrait 50×100 mm
(width × height) to match your earlier MeerK40t bookmark spec. Swap W and H if you switch
to landscape.
"""
from __future__ import annotations

import math

# Portrait bookmark: narrow width, long height (matches prior 50×100 mm spec).
W, H = 50.0, 100.0
# Tassel hole on cut layer (red), top center, ~3.5 mm diameter.
TASSEL_HOLE_R = 1.75
TASSEL_HOLE_CY = 4.0
GAP = 5.0
CUT = "#ff0000"
ENG = "#0000ff"
CUT_SW = 0.35
ENG_SW = 0.15
# Keep blue art slightly inside the cut rect so curves do not kiss the red stroke.
CLIP_INSET = 0.75


def polar(cx: float, cy: float, r: float, a_deg: float) -> tuple[float, float]:
    a = math.radians(a_deg)
    return cx + r * math.cos(a), cy + r * math.sin(a)


def ring_circles(cx: float, cy: float, r_ring: float, n: int, rr: float) -> str:
    parts = []
    for i in range(n):
        x, y = polar(cx, cy, r_ring, i * 360.0 / n)
        parts.append(
            f'<circle cx="{x:.3f}" cy="{y:.3f}" r="{rr:.3f}"/>'
        )
    return "".join(parts)


def ring_petals(cx: float, cy: float, r0: float, r1: float, n: int) -> str:
    d = []
    for i in range(n):
        a0 = (i - 0.5) * 360.0 / n
        a1 = (i + 0.5) * 360.0 / n
        x0, y0 = polar(cx, cy, r0, a0)
        xm, ym = polar(cx, cy, r1, i * 360.0 / n)
        x1, y1 = polar(cx, cy, r0, a1)
        d.append(f"M{x0:.2f},{y0:.2f}Q{xm:.2f},{ym:.2f} {x1:.2f},{y1:.2f}")
    return f'<path d="{" ".join(d)}"/>'


def mandala(cx: float, cy: float, rmax: float, style: str) -> str:
    out = []
    for k in range(1, 9):
        rr = rmax * k / 8.5
        n = 6 + k * 2
        if style == "hearts":
            out.append(ring_circles(cx, cy, rr, n, 0.35 + k * 0.02))
        elif style == "dots":
            out.append(ring_circles(cx, cy, rr, n * 2, 0.25))
        else:
            out.append(ring_petals(cx, cy, rr * 0.72, rr, n))
    return "".join(out)


def vine_field(
    x0: float,
    y0: float,
    w: float,
    h: float,
    seed: int,
    y_clip: float | None = None,
) -> str:
    """Deterministic squiggle grid. If y_clip is set, Y coordinates are clamped so
    quadratic splines stay inside the bookmark (avoids crossing the cut border)."""
    lines = []
    s = seed
    for j in range(12):
        for i in range(6):
            s = (s * 1103515245 + 12345) & 0x7FFFFFFF
            xa = x0 + (i + 0.15) * w / 6 + (s % 7) / 10
            ya = y0 + (j + 0.1) * h / 12 + ((s >> 8) % 5) / 10
            s = (s * 1103515245 + 12345) & 0x7FFFFFFF
            xb = xa + 2 + (s % 5)
            yb = ya + 4 + ((s >> 4) % 6)
            xc = xa - 1 + ((s >> 12) % 4)
            yc = ya + 7
            if y_clip is not None:
                margin = 0.8
                cap = y_clip - margin
                ya = min(ya, cap - 5.0)
                yb = min(yb, cap - 1.0)
                yc = min(yc, cap)
            lines.append(
                f"M{xa:.2f},{ya:.2f}Q{xb:.2f},{yb:.2f} {xc:.2f},{yc:.2f}"
            )
    return f'<path d="{" ".join(lines)}"/>'


def sunburst(cx: float, cy: float, r: float, rays: int) -> str:
    d = []
    for i in range(rays):
        a = i * 360.0 / rays
        x1, y1 = polar(cx, cy, r * 0.2, a)
        x2, y2 = polar(cx, cy, r, a + 180.0 / rays)
        d.append(f"M{cx:.2f},{cy:.2f}L{x1:.2f},{y1:.2f}M{cx:.2f},{cy:.2f}L{x2:.2f},{y2:.2f}")
    return f'<path d="{" ".join(d)}"/>'


def bookmark1_floral(ox: float, oy: float) -> str:
    yb = oy + H
    cx, cy = ox + 25, oy + 30
    parts = [
        mandala(cx, cy, 14, "petals"),
        ring_petals(cx, cy + 38, 6, 11, 10),
        ring_circles(cx, cy + 38, 8, 10, 0.4),
        mandala(ox + 15, oy + 76, 8, "dots"),
        vine_field(ox + 2, oy + 48, 46, 46, 101, y_clip=yb),
        ring_petals(ox + 38, oy + 80, 3, 6, 8),
    ]
    # small daisies
    for i in range(5):
        dx = ox + 8 + (i % 3) * 17
        dy = oy + 12 + (i // 3) * 22
        parts.append(ring_petals(dx, dy, 2.2, 4.5, 12))
        parts.append(ring_circles(dx, dy, 1.2, 1, 0.5))
    return "".join(parts)


def bookmark2_mandala_swirl(ox: float, oy: float) -> str:
    yb = oy + H
    parts = [
        mandala(ox + 25, oy + 22, 18, "petals"),
        ring_circles(ox + 25, oy + 22, 16, 24, 0.3),
        ring_petals(ox + 25, oy + 52, 5, 9, 14),
        vine_field(ox + 3, oy + 58, 44, 36, 202, y_clip=yb),
        mandala(ox + 25, oy + 84, 9, "hearts"),
    ]
    parts.append(sunburst(ox + 25, oy + 52, 12, 16))
    return "".join(parts)


def bookmark3_central_mandala(ox: float, oy: float) -> str:
    yb = oy + H
    cx, cy = ox + 25, oy + 50
    parts = [
        mandala(cx, cy, 20, "hearts"),
        ring_circles(cx, cy, 18, 32, 0.28),
        ring_petals(cx, cy, 16, 19, 20),
    ]
    parts.append(vine_field(ox + 2, oy + 2, 46, 22, 303, y_clip=oy + 46))
    parts.append(vine_field(ox + 2, oy + 74, 46, 22, 404, y_clip=yb))
    for i in range(8):
        px, py = polar(cx, cy, 22, i * 45)
        parts.append(ring_petals(px, py, 2, 4, 6))
    return "".join(parts)


def bookmark4_star_floral(ox: float, oy: float) -> str:
    yb = oy + H
    parts = [
        sunburst(ox + 25, oy + 50, 22, 24),
        mandala(ox + 25, oy + 50, 8, "dots"),
        ring_petals(ox + 25, oy + 22, 7, 12, 16),
        ring_petals(ox + 25, oy + 78, 7, 12, 14),
    ]
    for i in range(6):
        px = ox + 10 + (i % 3) * 15
        py = oy + 8 + (i // 3) * 15
        parts.append(ring_petals(px, py, 2.5, 5, 10))
    parts.append(vine_field(ox + 4, oy + 32, 42, 36, 505, y_clip=yb))
    parts.append(vine_field(ox + 3, oy + 2, 44, 18, 606, y_clip=oy + 22))
    return "".join(parts)


def cut_rect(ox: float, oy: float) -> str:
    return (
        f'<rect x="{ox:.3f}" y="{oy:.3f}" width="{W:.3f}" height="{H:.3f}" '
        f'fill="none" stroke="{CUT}" stroke-width="{CUT_SW}"/>'
    )


def cut_tassel_hole(ox: float, oy: float) -> str:
    cx = ox + W / 2
    cy = oy + TASSEL_HOLE_CY
    return (
        f'<circle cx="{cx:.3f}" cy="{cy:.3f}" r="{TASSEL_HOLE_R:.3f}" '
        f'fill="none" stroke="{CUT}" stroke-width="{CUT_SW}"/>'
    )


def cut_all(ox: float, oy: float) -> str:
    return cut_rect(ox, oy) + cut_tassel_hole(ox, oy)


def clip_defs_combined(oxs: list[float]) -> tuple[str, float, float]:
    iw, ih = W - 2 * CLIP_INSET, H - 2 * CLIP_INSET
    defs = ["<defs>"]
    for i, ox in enumerate(oxs):
        cid = f"clip-bm-{i}"
        defs.append(
            f'<clipPath id="{cid}"><rect x="{ox + CLIP_INSET:.3f}" y="{CLIP_INSET:.3f}" '
            f'width="{iw:.3f}" height="{ih:.3f}"/></clipPath>'
        )
    defs.append("</defs>")
    return "".join(defs), iw, ih


def main() -> None:
    total_w = 4 * W + 3 * GAP
    oxs = [i * (W + GAP) for i in range(4)]

    gens = [
        bookmark1_floral,
        bookmark2_mandala_swirl,
        bookmark3_central_mandala,
        bookmark4_star_floral,
    ]
    engrave_wrapped = []
    defs_parts, iw, ih = clip_defs_combined(oxs)
    for i, (ox, gen) in enumerate(zip(oxs, gens)):
        engrave_wrapped.append(
            f'<g clip-path="url(#clip-bm-{i})">{gen(ox, 0)}</g>'
        )

    cuts = "".join(cut_all(ox, 0) for ox in oxs)

    svg = f'''<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg"
     width="{total_w:.3f}mm" height="{H:.3f}mm"
     viewBox="0 0 {total_w:.3f} {H:.3f}">
  <title>Zentangle bookmarks — MeerK40t</title>
  <!-- Cut: red (#ff0000) matches default Cut ops. Engrave: blue (#0000ff) matches default Engrave ops. -->
  <!-- Engrave: set speed / PPI on your Engrave op in MeerK40t. -->
  {defs_parts}
  <g id="engrave-art" fill="none" stroke="{ENG}" stroke-width="{ENG_SW}"
     stroke-linecap="round" stroke-linejoin="round">
    {"".join(engrave_wrapped)}
  </g>
  <g id="cut-outline" fill="none" stroke-linecap="square" stroke-linejoin="miter">
    {cuts}
  </g>
</svg>
'''
    base = __file__.replace("gen_bookmarks_svg.py", "")
    out = base + "bookmarks-zentangle-4x50x100mm.svg"
    with open(out, "w", encoding="utf-8") as f:
        f.write(svg)
    print(out)

    singles = [
        ("01", bookmark1_floral),
        ("02", bookmark2_mandala_swirl),
        ("03", bookmark3_central_mandala),
        ("04", bookmark4_star_floral),
    ]
    iw_s, ih_s = W - 2 * CLIP_INSET, H - 2 * CLIP_INSET
    for num, gen in singles:
        one = f'''<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg"
     width="{W:.3f}mm" height="{H:.3f}mm"
     viewBox="0 0 {W:.3f} {H:.3f}">
  <title>Zentangle bookmark {num} — MeerK40t</title>
  <defs>
    <clipPath id="clip-inner">
      <rect x="{CLIP_INSET:.3f}" y="{CLIP_INSET:.3f}" width="{iw_s:.3f}" height="{ih_s:.3f}"/>
    </clipPath>
  </defs>
  <g id="engrave-art" fill="none" stroke="{ENG}" stroke-width="{ENG_SW}"
     stroke-linecap="round" stroke-linejoin="round" clip-path="url(#clip-inner)">
    {gen(0, 0)}
  </g>
  <g id="cut-outline" fill="none" stroke-linecap="square" stroke-linejoin="miter">
    {cut_all(0, 0)}
  </g>
</svg>
'''
        p = base + f"bookmark-zentangle-{num}-50x100mm.svg"
        with open(p, "w", encoding="utf-8") as f:
            f.write(one)
        print(p)


if __name__ == "__main__":
    main()
