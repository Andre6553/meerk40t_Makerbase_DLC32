# Repository map (clone root)

Assume clone root: `...\meerkat\meerk40t\`.

## Top-level (repo)

| Path | Role |
|------|------|
| `meerk40t.py` | Launches `meerk40t.main:run()` |
| `meerk40t/` | **Python package** — almost all application code |
| `test/`, `testgui/` | Automated tests |
| `docs/` | Upstream documentation (different from `...\meerkat\docs\meerk40t\`) |
| `locale/` | Translations |
| `tools/` | Build scripts (e.g. Windows PyInstaller), helpers |
| `requirements*.txt` | Dependency sets |

## Package `meerk40t/` (high level)

| Path | Role |
|------|------|
| `main.py` | CLI args, kernel construction, plugin bootstrap |
| `internal_plugins.py` | **Master list** of built-in plugins (order matters) |
| `external_plugins.py` | Entry point group `meerk40t.extension` for add-ons |
| `kernel/` | Kernel, context, channels, console decorators, jobs, modules |
| `core/` | Elements, planner, spoolers, SVG I/O, logging, webhelp, etc. |
| `gui/` | wxPython UI: main window, panels, icons, themes |
| `device/` | Shared device abstractions (`basedevice` plugin) |
| `lihuiyu/` | K40 / Lihuiyu M2/M3-Nano driver stack |
| `grbl/` | GRBL family |
| `ruida/` | Ruida + emulation pieces |
| `balormk/` | JCZ / Ezcad-style galvo (`balormk`) |
| `moshi/`, `newly/` | Other controller families |
| `camera/`, `dxf/` | Camera and DXF plugins |
| `image/`, `fill/` | Raster / fill / pattern tooling |
| `extra/` | Many optional features (potrace, inkscape bridge, updater, …) |
| `network/` | Kernel server / remote control hooks |

## “Where do I start reading for X?”

| Question | Start here |
|----------|--------------|
| Boot & flags | `meerk40t/main.py` |
| What plugins exist | `meerk40t/internal_plugins.py` |
| Kernel behavior | `meerk40t/kernel/kernel.py` (`Kernel`) |
| Cut planning | `meerk40t/core/planner.py` |
| Laser UI (arm/start) | `meerk40t/gui/laserpanel.py`, `meerk40t/gui/wxmmain.py` |
| K40 USB | `meerk40t/lihuiyu/` (+ `plugin.py`) |
