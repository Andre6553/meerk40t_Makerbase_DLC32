# Drivers and plugins

## Internal plugins (shipped with MeerK40t)

Authoritative **order and membership**: `meerk40t/internal_plugins.py`, function `plugin(kernel, lifecycle)`, branch `lifecycle == "plugins"`.

Summary (as in that file — names are import paths / roles):

| Plugin source | Typical role |
|---------------|----------------|
| `network.kernelserver` | Remote / server hooks |
| `device.basedevice` | Base device infrastructure |
| `extra.coolant` | Coolant integration |
| `lihuiyu` | **Lihuiyu / K40-class boards** |
| `moshi` | Moshiboard |
| `grbl.plugin` | GRBL controllers |
| `ruida` | Ruida + related |
| `rotary`, `cylinder` | Rotary / cylindrical workflows |
| `core.core` | Elements, planner, spoolers, SVG, … |
| `imagetools`, `fills`, `patterns` | Raster / fills |
| `extra.vectrace`, `potrace`, `vtracer` | Tracing |
| `extra.inkscape`, `ezd`, `lbrn`, `xcs_reader` | External format bridges |
| `extra.updater`, `winsleep`, `param_functions`, `serial_exchange` | Utilities |
| `camera.plugin` | Camera |
| `dxf.plugin` | DXF |
| `extra.cag` | Constructive area geometry |
| `balormk.plugin` | Galvo / JCZ-style |
| `newly.plugin` | NewlyDraw |
| `gui.plugin` | **wxPython UI** |
| `extra.imageactions`, `extra.outerworld` | Extra UI / IO helpers |

Note: `balormk` and `newly` use `kernel.add_plugin(...)` inside the same function instead of only appending to the returned list—same lifecycle, slightly different registration path.

## External plugins

`meerk40t/external_plugins.py`:

- Entry point group: **`meerk40t.extension`**
- Loaded via `importlib.metadata` (or `pkg_resources` on older Python), unless:
  - frozen executable build (then external discovery is skipped), or
  - `--no-plugins` / `kernel.args.no_plugins`

Third-party packages can expose plugins without forking core.

## Driver `plugin.py` files (examples)

Each major subsystem often has `plugin.py` registering:

- Device types, services, console commands
- GUI panels (device configuration, live controls)

Examples under `meerk40t/`:

- `lihuiyu/plugin.py`
- `grbl/plugin.py`
- `ruida/plugin.py`
- `balormk/plugin.py`
- `moshi/plugin.py`
- `newly/plugin.py`
- `gui/plugin.py`
- `camera/plugin.py`
- `dxf/plugin.py`

## “Which driver am I using?”

In the GUI, the **device** label in the title bar and the **device combo** on the laser panel reflect `kernel.device` / root device context. Your screenshot showed **`lihuiyu-device`** → start reading under `meerk40t/lihuiyu/`.
