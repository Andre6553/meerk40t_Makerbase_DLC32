# GUI architecture (wxPython)

## Stack

- **`wx.App` subclass** — `wxMeerK40t` in `meerk40t/gui/wxmeerk40t.py`: application lifecycle, timer tied to kernel scheduler, DPI awareness on Windows.
- **Main frame** — `MeerK40t` in `meerk40t/gui/wxmmain.py` (`class MeerK40t(MWindow)`): AUI panes, menus, toolbars, job-start buttons, title bar (`__set_titlebar`).
- **Base frame helper** — `MWindow` in `meerk40t/gui/mwindow.py`: sizing persistence, theme colors, module open/close.
- **Panels** — Registered as AUI panes (`register_panel_*` functions, e.g. `gui/consolepanel.py` registers **Console** bottom pane).

## Important GUI files

| File | Responsibility |
|------|----------------|
| `gui/plugin.py` | Boots GUI: busy splash, opens `module/wxMeerK40t`, `window open MeerK40t`, restores panes |
| `gui/wxmeerk40t.py` | `wx.App` + kernel module glue |
| `gui/wxmmain.py` | Main window, menus, job toolbar, many `kernel.register("button/...")` entries |
| `gui/laserpanel.py` | Device selection, start/pause/stop, **arm** toggle, power/speed overrides |
| `gui/consolepanel.py` | Console pane + console commands for font/clear |
| `gui/themes.py` | Colors including **arm** / **stop** / **start** button themes |
| `gui/wxmscene.py` | Scene / workspace rendering (large file) |

## Docking / layout

Uses **wx.lib.agw.aui** (AUI). Panes can float, dock, hide. User layout persists when `windows_save` (see `MWindow`) is enabled.

## Simple UI

Flag `-w` / `--simpleui` skips the full main window and opens **SimpleUI** instead (`gui/plugin.py` references `window open SimpleUI`).

## Signals in the GUI

Panels use `@signal_listener` to react without tight coupling—for example laser panel listens to `"laser_armed"` and `"laserpane_arm"` to refresh arm/start state.
