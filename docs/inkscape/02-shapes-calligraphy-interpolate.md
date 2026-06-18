# Inkscape — shapes, calligraphy, interpolate, design

Distilled from official **Shapes**, **Calligraphy**, **Interpolate**, and **Elements of design** tutorials.

## Shape tools (general)

- New shape: drag on canvas. Handles = white diamonds/squares/circles.
- Handles visible in shape tool **and** Node tool (N).
- Tool Controls bar sets params for selected shapes **and** defaults for **next** drawn shape.
- Selecting a shape copies its params to the bar → affects new shapes of that type.
- **Convert to path:** Ctrl+Shift+C (irreversible for shape editing).

## Rectangle (R)

- **Ctrl** while drawing: square or integer ratio (2:1, 3:1…).
- **Shift:** draw from center.
- **Rounding handles** (top-right corner, two overlapping): drag for rounded corners; Ctrl = circular (match other radius); Shift+click = sharp corners.
- **Resize handles:** scale along rectangle's own axes (works when rotated/skewed — unlike Selector).
- Selector bar: **Scale rounded corners** toggle — off keeps corner radius constant when scaling (diagram boxes).
- Rx/Ry in Controls bar for precise radii.

## Ellipse (E)

- Same Ctrl/Shift drawing modifiers as rectangle.
- **Right handle (two overlapping):** drag to open into **segment** (outside) or **arc** (inside, unclosed stroke).
- Ctrl on arc handle: 15° snap. Shift+click: whole ellipse.
- Other handles: resize in ellipse coordinates; Ctrl = circle.

## Star / polygon

- Toggle star vs polygon in Controls bar; vertices 3–1024 (stars from 2 tips).
- Ctrl while drawing: 15° angle snap.
- **Vertex handle:** ray length; rotates with constraint on other handle.
- **Inner handle:** skew tips (crystals, snowflakes); Ctrl = radial only (no skew).
- **Spoke ratio** in Controls bar.
- **Shift+drag handle tangentially:** rounding (unlike rectangle — smooth curvature, no straight sides).
- **Alt+drag tangentially:** randomize; Alt+click removes randomization.
- **Offset (Ctrl+J)** from star: sharp tips + smooth concaves.

## Spiral

- Draw from center; Ctrl = 15° snap.
- **Outer handle:** roll/unroll turns (max 1024). Shift+drag: scale/rotate without rolling. Alt+drag: lock radius while rolling.
- **Inner handle:** Alt+vertical = divergence (<1 denser outside, >1 denser center); Alt+click reset divergence; Shift+click move inner to center.
- Dotted stroke on spirals: moiré effects.

## Calligraphy (C / Ctrl+F6)

Best with **tablet** (pressure/tilt — configure Edit → Input Devices before launch, toggle on toolbar).

| Param | Role |
|-------|------|
| Width | 1–100 (% of window, zoom-independent by default) |
| Thinning | −100…100; velocity → width (0 = constant; + = fast thinner) |
| Angle | 0° horizontal … ±90° vertical; up/down keys or tilt |
| Fixation | 100 = fixed angle; 0 = pen perpendicular to stroke (sans-serif look) |
| Mass | Inertia / smoothing (default 2) |
| Wiggle | Paper slip (0 = none) |
| Tremor | 0–100 organic unevenness |
| Caps | Line ends |

- Width: left/right arrows while drawing; mouse users often set **Thinning = 0**.
- Traditional hands: e.g. Uncial ≈ 25° angle, guides for slant.
- Bad stroke: Ctrl+Z; slight misplacement: Space → Selector nudge → Space back.

## Interpolate extension

**Extensions → Generate From Path → Interpolate Between Paths**

- Inputs must be **paths** (Ctrl+Shift+C first).
- **Steps:** number of intermediate copies between paths.
- **Starting node** matters (Node tool, Tab to first node) — affects twist when paths differ.
- **Interpolation method:** (1) Split into equal segments vs (2) Discard extra nodes of longer path.
- **Exponent:** spacing between steps (1 = even); **selection order** affects exponent direction.
- **Duplicate endpaths:** include originals in result group.
- **Interpolate Style:** morph fill/stroke between endpoints — can fake irregular gradients (pre-mesh).

## Elements and principles of design (reference)

**Elements:** line, shape (geometric/organic), size, space (positive/negative), color (hue/value/intensity), texture, value (chiaroscuro).

**Principles:** balance (symmetric/asymmetric), contrast, emphasis/focal point, proportion, pattern, gradation (perspective, movement).

Use when advising composition for laser/CNC/print prep — not Inkscape-specific mechanics.
