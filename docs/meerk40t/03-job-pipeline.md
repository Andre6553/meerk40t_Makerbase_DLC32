# Job pipeline (conceptual)

This is the **high-level data path** from design to machine—not every edge case.

## 1. Elements (the “document”)

User content (paths, images, operations, groups) lives in the **element tree**, managed by the **elements** plugin (`meerk40t/core/elements/`). Classification, pen boxes, SVG import, etc. hang off this.

**Core plugin registration** (`meerk40t/core/core.py`, `lifecycle == "plugins"`):

- `spoolers`, `space`, `elements`, `penbox`, `logging`, `bindalias`, `webhelp`, `planner`, `svg_io`

So: **elements + planner + spoolers** are siblings under `core`.

## 2. Planning

The **planner** (`meerk40t/core/planner.py`) prepares **plans**: ordered work derived from elements (including optimization passes when enabled). Console / UI often reference `plan0`, `plan1`, … style operations (see laser job registration in `wxmmain.py` where `plan{new_plan}` is built).

Typical verbs in UI flow include **clear**, **copy**, **preprocess**, **validate**, **blob**, optional **optimize**, then **spool** (exact sequence depends on settings).

## 3. Spooler

**Spoolers** (`meerk40t/core/spoolers.py`) manage the **queue of laser jobs**: what runs now, paused, completed. The **Job spooler** window is part of normal GUI workflow.

## 4. Device driver

The active **device** (e.g. Lihuiyu, GRBL) translates spooled operations into **hardware protocol** (USB bulk, serial, UDP, etc.). Driver code lives under `meerk40t/<driver>/` with its own `plugin.py`.

## 5. Safety / gating

Examples you have seen:

- **Arm / disarm** — sets `kernel.root._laser_may_run` and ties into **Start** enablement (`laserpanel.py`, `wxmmain.py`).
- **Pause / stop** — driver and UI listen for run state.

For **planner + spooler internals** (stages, `LaserJob`, `spool` command, thread model), see [07-planner-and-spooler.md](07-planner-and-spooler.md).

## Reading order for “how does a burn start?”

1. `gui/wxmmain.py` — `button/jobstart/ExecuteLaser`, `run_job`, `may_run`
2. `gui/laserpanel.py` — start button, arm toggle, device combo
3. `core/planner.py` — how plans are built
4. `core/spoolers.py` — execution queue
5. Your driver folder (`lihuiyu/`, `grbl/`, …) — low-level packets
