# Core elements, space, and file I/O

How the **document model** and **imports/exports** hang off the kernel—shared by all drivers.

---

## 1. Elements service (`meerk40t/core/elements/elements.py`)

The module docstring summarizes responsibility:

- **Tree** of nodes: geometry, groups, **operations** (cut, engrave, raster, image, dots, …).
- **Undo**, classification, penbox, wordlists, offsets.

**Plugin** `elements.plugin` runs across lifecycles (`register`, `preregister`, `postboot`, …) and registers a large surface of **console** commands and element-manipulation hooks (file is thousands of lines—use search for a specific verb).

**Key types** (imports at top of `elements.py`): `RootNode`, `CutOpNode`, `EngraveOpNode`, `RasterOpNode`, `ImageOpNode`, `DotsOpNode`, etc.

**Access:** Kernel exposes `kernel.elements` as the primary API surface from other modules (planner copies from `elements.ops()`, etc.).

---

## 2. Core plugin bundle (`meerk40t/core/core.py`)

Under `lifecycle == "plugins"` the **core** aggregator pulls in, in order:

`spoolers` → `space` → **`elements`** → `penbox` → `logging` → `bindalias` → `webhelp` → **`planner`** → **`svg_io`**

- **`space`** — workspace / scene coordinate helpers tied to the scene.
- **`svg_io`** — SVG import/export pipeline.
- **`penbox`** — reusable pen / parameter sets.
- **`logging`** — structured log / uid helpers used by jobs.

---

## 3. Base device (`meerk40t/device/basedevice.py`)

Registers **boot behavior** for devices:

- **`lifecycle == "boot"`** — Restores **`activated_device`** from persistent settings; if no device exists, starts **`preferred_device`** (default string **`lhystudios`**).
- Defines **plot / driver state constants** used across drivers, e.g. **`PLOT_FINISH`**, **`PLOT_JOG`**, **`PLOT_RAPID`**, **`PLOT_SETTING`**, **`DRIVER_STATE_PROGRAM`**, etc.

Drivers and **`PlotPlanner`** agree on these flags so cut planning stays device-agnostic until the driver.

**Console:** e.g. **`viewport_update`** (hidden) calls `kernel.device.realize()` when present.

---

## 4. DXF and camera (separate plugins)

| Plugin | Path | Role |
|--------|------|------|
| **dxf** | `meerk40t/dxf/plugin.py` | DXF import/export (`load` registration). |
| **camera** | `meerk40t/camera/plugin.py` | Camera alignment / capture workflows. |

See `internal_plugins.py` for load order relative to GUI.

---

## 5. Other loaders (examples)

| Registration key | Typical file |
|--------------------|----------------|
| `load/GCodeLoader` | `grbl/loader.py` |
| `load/RDLoader` | `ruida/loader.py` |
| `load/EgvLoader` | `lihuiyu/loader.py` (optional import) |

Use **`kernel.find("load", ...)`** or search `kernel.register("load/` in the repo to enumerate all.

---

## 6. Reading order

1. `core/core.py` — plugin list only (quick).
2. `core/elements/elements.py` — docstring + search `console_command` for verbs you need.
3. `device/basedevice.py` — boot device selection + constants.
4. `core/svg_io` / `core/planner.py` — how elements become plans (with [07](07-planner-and-spooler.md)).
