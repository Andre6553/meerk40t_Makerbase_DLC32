# Inkscape — troubleshooting and performance

Distilled from **Customize tools**, **Invisible objects**, **Select individual object**, **Avoid performance issues**, and **LaTeX** tutorials.

## #1 beginner issue: tools "remember" last style

By default, each tool copies the **style** (fill, stroke, opacity, width, shape params) of the **last object drawn with that tool**.

Symptoms: no visible stroke, transparent fill, ellipse only draws arcs, rounded rects stuck on, "nothing draws."

### Fix transparency

Check all of:

1. **Fill and Stroke** (Shift+Ctrl+F): Fill/Stroke **A** slider = 255; bottom **Opacity** = 100%.
2. **Layers** dialog: layer opacity 100%, eye open, blend Normal.
3. Fill/Stroke **X button** (no paint) vs solid flat color button.

### Fix shape-tool weirdness

- **Star / Spiral:** reset button on **far right** of tool Controls bar.
- **Rectangle:** "Make corners sharp" button.
- **Ellipse:** "Make whole" button (closes arc/segment).

### Lock a permanent tool style

1. Draw one object with desired style; keep selected.
2. **Double-click tool icon** in toolbar → Preferences for that tool.
3. **Create new objects with:** → **This tool's own style** → **Take from selection**.

Path tools (Pencil, Pen, Calligraphy, Spiral): often **stroke only, no fill**.

### Style indicators

- **Top-right:** style for active tool.
- **Bottom-left:** selected object style; right-click bars for quick changes; stroke width number on bar.

## Can't select parts of imported art

Use **status bar** (bottom center):

| Status starts with | Meaning | Action |
|--------------------|---------|--------|
| **Image…** | Raster | Trace (Path → Trace Bitmap) or manual Pen trace; can't select vector parts |
| **Group of…** | Nested groups | Object → Ungroup (Shift+Ctrl+G) repeat, or Extensions → Arrange → Deep Ungroup |
| **Path…** | Compound path | Path → Break Apart; if all goes black, add stroke / remove fill to see pieces |

After Trace Bitmap: almost always **ungroup** once.

## Performance (slow, freeze, crash)

Primary cause: **file complexity** vs system resources.

Contributors: embedded rasters, filters/blur, many nodes, many gradients, unused defs, Objects dialog left open, extreme zoom, heavy extensions.

### Mitigations (in order)

1. **File → Clean Up Document** (was Vacuum Defs in old versions).
2. **Layers:** hide unused layers.
3. Heavy visible content: hide working layers → select all visible → **Edit → Make Bitmap Copy** → move bitmap to layer; unhide work layers; delete bitmap when done.
4. **View → Display Mode → Outline** (fastest) or **No Filters**.
5. **Link** images instead of embed when possible; delete reference images when done.
6. **Path → Simplify** on problem paths only (not whole drawing); adjust threshold in Preferences → Behavior → Simplification.
7. Pencil: **LPE Based Interactive Simplify** on control bar (0.92+).
8. Preferences → Rendering: thread count, blur/filter display quality (multi-core laptops).
9. Don't leave **Objects** dialog open continuously.
10. **AutoSave:** Preferences → Input/Output → AutoSave (1.0+).

## LaTeX

### Embed formula in drawing

- **Extensions → Text → Formula (pdflatex)** (1.3+); older: Extensions → Render → Formula.
- Requires: `latex`, `dvips`, `pstoedit` on PATH (Linux: `texlive`, `pstoedit`). Alternative: **textext** extension.

### Inkscape → LaTeX document

- **File → Save a Copy → EPS**; `\includegraphics{file.eps}` in LaTeX.

### PDF+LaTeX (0.48+)

- Export PDF+LaTeX: geometry in PDF, text in `.tex` sidecar; compile LaTeX to rebuild drawing. Also EPS+LaTeX / PS+LaTeX. See CTAN "SVG in LaTeX".

### LyX

Preamble needs `graphicx`, `xcolor`, `transparent`, etc.; insert `\input{example.pdf_tex}` in figure float.

## Linux Alt+click note

Window managers may capture Alt+click (workspace switch). Rebind WM or use Meta key so Inkscape gets Alt for select-under and Alt+drag.
