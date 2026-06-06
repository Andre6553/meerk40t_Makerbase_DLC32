# MeerK40t — overview

## What it is

MeerK40t is **MIT-licensed** laser control software: vector/raster workflows, multiple **device drivers**, and a **wxPython** GUI (optional; headless / CLI modes exist).

Entry point: `meerk40t/main.py` → `run()` → `_exe()` builds a **`Kernel`**, registers **internal + external plugins**, then invokes the kernel (see `kernel(...)` at end of `_exe`).

## Architectural mental model

1. **Kernel** — Central hub: settings persistence, **scheduler**, **signals**, **channels**, **console** command registry, plugin lifecycle, device list. See class docstring in `meerk40t/kernel/kernel.py` (`Kernel`).

2. **Plugins** — Almost everything is a plugin loaded via lifecycle strings (`"plugins"`, `"preregister"`, `"register"`, etc.). The **ordered internal list** starts in `meerk40t/internal_plugins.py` (`plugin(..., lifecycle=="plugins")`).

3. **Context** — Hierarchical settings and command routing; devices and UI attach to contexts under `kernel.root` and subpaths.

4. **Elements** — User geometry / operations live in the element tree (registered by `meerk40t/core/elements`).

5. **Planner / spoolers** — Turn plans into work the device can execute (`meerk40t/core/planner.py`, `meerk40t/core/spoolers.py`).

6. **Drivers** — Device-specific USB/serial/network protocols and machine configuration (`meerk40t/lihuiyu/`, `meerk40t/grbl/`, `meerk40t/ruida/`, etc.).

7. **GUI** — `meerk40t/gui/plugin.py` loads wxApp, opens main window, registers panes (AUI). Same kernel; UI sends **console** strings and listens to **signals**.

## Version string you see in the title bar

From `meerk40t/main.py`: `APPLICATION_VERSION` is extended with `git <branch>` when running from a tree that contains `.git`.

## Modes worth knowing

| Mode | Typical trigger |
|------|-------------------|
| Full GUI | Default double-click / `python meerk40t.py` |
| No GUI | `-z` / `--no-gui` |
| Console emphasis | `-c` / `--console` |
| Execute then exit | `-e "command"` (can combine with other flags) |
| Simple UI | `-w` / `--simpleui` |

Server-style substrings in `-e` commands switch **partial** kernel mode (see `_exe` in `main.py` around `lhyserver`, `grblserver`, `ruidacontrol`, etc.).

## Maintenance reality

Upstream describes **maintenance mode** (slower PR/issue cadence). Treat this doc as **community-maintained** alongside the code.
