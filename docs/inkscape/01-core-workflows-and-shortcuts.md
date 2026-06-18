# Inkscape — core workflows and shortcuts

Distilled from official **Basic**, **Advanced**, and **Tips and Tricks** tutorials.

## Navigation and documents

- **Pan:** Ctrl+arrows, middle-drag, scrollbars (Ctrl+B toggle), mouse wheel; Shift+wheel = horizontal.
- **Zoom:** `-` / `+` (or `=`), Ctrl+middle/right-click zoom in, Shift+middle/right-click zoom out, Ctrl+wheel, Zoom tool (drag area), type % in status-bar **Z** field. `` ` `` = previous zoom; Shift+`` ` `` = forward.
- **New:** Ctrl+N; template: Ctrl+Alt+N. **Open/Save:** Ctrl+O / Ctrl+S / Shift+Ctrl+S.
- **Switch documents:** Ctrl+Tab (same Inkscape process only).
- Native format: **SVG** (XML). Many import/export formats available.

## Tools and selection

| Tool | Key | Notes |
|------|-----|-------|
| Selector | S, F1, Space toggle | Move, scale, rotate, skew |
| Node | N | Edit path nodes |
| Zoom | Z | |
| Rectangle | R | |
| Ellipse | E | |
| Star | * | Polygon or star |
| Spiral | * | |
| Pen (Bezier) | B | |
| Pencil (freehand) | P | |
| Text | T | |
| Gradient | G | |
| Dropper | D, F7 | Pick fill; Shift+click = stroke |
| Calligraphy | C, Ctrl+F6 | |
| Shape Builder | X | Click sections to keep/remove |

**Multi-select:** Shift+click; rubberband drag (Shift before drag = always rubberband); Alt = pencil-select through stack.
**Deselect:** Esc. **Select all (layer):** Ctrl+A.
**Select under:** Alt+click cycles z-order at point; Alt+wheel cycles objects under cursor. **Drag selection without re-picking top:** Alt+drag.
**Select same:** Edit → Select Same (fill, stroke, type, etc.).
**Tab / Shift+Tab:** cycle objects in z-order.

## Transform shortcuts (Selector or nodes)

- Move: arrows (2 px); Shift = 10×; **Alt+arrows = 1 screen pixel** (precision at high zoom).
- Scale: `<` `>`; Ctrl = 200%/50%; Alt = 1 px visible size change.
- Rotate: `[` `]` (15°); Ctrl = 90°; Alt = 1 px at farthest point.
- With Selector: click twice for rotate/skew handles; drag cross = rotation center.

## Grouping and z-order

- **Group/Ungroup:** Ctrl+G / Ctrl+U (top level only; repeat or Extensions → Arrange → Deep Ungroup).
- **Edit inside group:** double-click group; double-click empty canvas to exit. Ctrl+click selects child without ungrouping.
- **Z-order:** Home/End = top/bottom; PgUp/PgDn = one step.

## Fill, stroke, alignment

- **Fill and Stroke dialog:** Shift+Ctrl+F — tabs: Fill, Stroke paint, Stroke style; flat, gradient, pattern, mesh.
- **Gradient tool (G):** drag handles; add stops (double-click line or Insert stop).
- **Align and Distribute:** Shift+Ctrl+A — align to **Page** via Relative to: Page.
- **Duplicate:** Ctrl+D (stacked on original, selected).
- **Paste In Place:** Ctrl+Alt+V. **Paste Style:** Shift+Ctrl+V (fill/stroke/font, not shape).

## Paths (Advanced)

- **Object to Path:** Ctrl+Shift+C (one-way; loses shape-specific params).
- **Combine / Break Apart:** Ctrl+K / Ctrl+Shift+K (compound path; overlapping fills can create holes).
- **Boolean ops (Path menu):** Union, Difference, Intersection, Exclusion; **Split Path**, **Fracture**, **Flatten** preserve colors better.
- **Shape Builder (X):** click add section, Shift+click hole, drag connect; Shift+click+drag remove region.
- **Inset / Outset:** Ctrl+( / Ctrl+); **Dynamic offset:** Ctrl+J (draggable handle); linked offsets stay tied to source.
- **Simplify:** Ctrl+L (threshold scales with selection size; rapid repeat increases threshold).
- **Stroke to Path:** outline stroke as filled path.

## Pen and Pencil

- Pen: click = corner node; drag = smooth Bezier; Shift while dragging = one handle free; Enter finish, Esc cancel, Backspace remove last segment.
- Continue path: select path, draw from end anchor; Shift from arbitrary point = new subpath.
- Unfinished path: Esc cancels all; Backspace removes last segment (not Undo).

## Text

- **Text and Font:** Shift+Ctrl+T.
- **Letter spacing:** Alt+< / Alt+> (1 px per zoom); **kern pair:** Alt+arrows between letters.
- **Line spacing:** Ctrl+Alt+< / >.
- **Flowed text:** click-drag text box with Text tool.
- **Put on Path:** select text + path → Text → Put on Path (prefer dedicated path, not live artwork).
- **Jump to source:** Shift+D (text on path, clone, linked offset).

## Useful tips (Tips tutorial)

- **Radial clones:** Tiled Clones → P1, Shift tab −100% X/Y, Rotation tab per column; or set rotation center (double-click object in Selector) then Create Tiled Clones.
- **Non-linear gradients:** multi-stop gradients along one line.
- **Eccentric radial:** Gradient tool, Shift+drag center handle for focus.
- **Mesh gradients:** Mesh tool below Gradient on toolbar.
- **Stamping:** drag/scale/rotate + **Space** while holding mouse.
- **Clean Up Document:** File menu — removes unused defs.
- **XML editor:** Shift+Ctrl+X.
- **Document units:** Shift+Ctrl+D → Display units.
- **Crisp 24×24 icon export:** 24×24 px doc, 0.5 px grid, even grid = fill, odd = stroke (even px width), export 96 dpi.
- **Drop shadow:** Filters → Shadows and Glows, or duplicate + PgDn + blur in Fill and Stroke.
- **EPS/PS:** no transparency — use Dropper to pick visible color without alpha.

## Paste size variants

Edit → Paste → Size / Width / Height / … Separately — scale selection to match clipboard object dimensions.
