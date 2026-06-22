# MeerK40t knowledge base (local)

This folder is **your** reference for asking questions about MeerK40t in Cursor. It is **not** part of the upstream `meerk40t/meerk40t` repository unless you copy it there.

## How to use with the AI

- **@ mention** these files (or the whole `docs/meerk40t` folder) when you ask behavior questions.
- After `git pull` on the clone, **refresh** docs when something feels stale (version numbers, new plugins).

## Recent local changes (Meerkat workspace)

Edits to the clone in this workspace (simulation cancel, tips persistence, MKS DLC32 info, etc.) are summarized here:

- **[15-meerkat-local-changes.md](15-meerkat-local-changes.md)** — changelog of fork-style GUI and rule updates (line tool click-on-geometry + precise preview v0.9.9032, start new line on existing line v0.9.9031, middle-mouse pan while drawing v0.9.9030, camera Enter-key crash fix v0.9.9029, camera paste URL/IP connect v0.9.9028, camera align offset crash fix v0.9.9027, camera bed MemoryDC composite v0.9.9026, camera bed photo draw fix v0.9.9025, camera bed apply crash fix v0.9.9024, camera Update Image console fix v0.9.9023, camera bed direct widget apply v0.9.9022, camera bed direct scene push v0.9.9021, camera bed grey regression fix v0.9.9020, camera bed full resolution v0.9.9019, camera Update Image live bitmap v0.9.9018, camera Update Image grey fix v0.9.9017, camera calib window fit v0.9.9016, camera fine alignment mm v0.9.9015, camera flip crash fix v0.9.9014, camera flip 180° v0.9.9013, camera corner markers v0.9.9012, Camera Calibration recursion fix v0.9.9011, Camera Calibration v0.9.9009, CSV Batch Run v0.9.9004, Plan Export SD-ready LF/M3, ESP3D filename dialog, GRBL false-connect / sync-mode fix, Laser-Control progress bar, tree op double-click → Parameter-Test, GRBL overrides, 2026).
- **[16-mks-dlc32-board.md](16-mks-dlc32-board.md)** — MKS DLC32 specs, GRBL setup, **touch-panel laser test (short beam)**, Cloudray **WP**, motors/Vref, limits.
- **[19-dlc32-eeprom-settings.md](19-dlc32-eeprom-settings.md)** — **Andre’s confirmed DLC32 EEPROM** (full `$$`; Cursor rule `.cursor/rules/dlc32-eeprom-settings.mdc`).
- **[17-meerkat-dlc32-workflow.md](17-meerkat-dlc32-workflow.md)** — Learning-phase workflow: Material Test, Material Manager presets, **K40 CO2 — MKS DLC32 (400×285 mm)** device profile, macros, **§8 Wi‑Fi/USB**, **§9 inner shapes not cutting**.
- **[18-meerk40t-ui-manual.md](18-meerk40t-ui-manual.md)** — **Illustrated UI manual** (§0 uses your June 2026 screenshots in `images/meerk40t-ui-manual/`); PDF via `scripts/build-ui-manual-pdf.ps1`.

## Contents

| File | What it covers |
|------|----------------|
| [00-overview.md](00-overview.md) | Big picture: kernel, plugins, GUI vs headless |
| [01-repository-map.md](01-repository-map.md) | Where code lives in the clone |
| [02-kernel-console-signals.md](02-kernel-console-signals.md) | Kernel hub, console commands, channels, signals |
| [03-job-pipeline.md](03-job-pipeline.md) | Elements → planner → spool → device (conceptual) |
| [04-drivers-and-plugins.md](04-drivers-and-plugins.md) | Internal plugin list + external extensions |
| [05-gui-architecture.md](05-gui-architecture.md) | wxPython app, main window, panes, laser panel |
| [06-lihuiyu-k40-first-dive.md](06-lihuiyu-k40-first-dive.md) | Lihuiyu / K40: first reading order |
| [07-planner-and-spooler.md](07-planner-and-spooler.md) | CutPlan stages, Planner, Spooler, LaserJob, console hooks |
| [08-grbl.md](08-grbl.md) | GRBL device/driver, connections, `grblcontrol`, buffer `hold_work` |
| [09-ruida.md](09-ruida.md) | Ruida: RDJob, emulator, UDP ports, `ruidacontrol`, MITM / bridge |
| [10-lihuiyu-deep.md](10-lihuiyu-deep.md) | Lihuiyu: plugin table, `lhyserver`, USB commands, file layout |
| [11-core-elements-and-io.md](11-core-elements-and-io.md) | Elements tree, basedevice boot, SVG/DXF/camera pointers |
| [12-balormk-galvo.md](12-balormk-galvo.md) | JCZ / EZCad-style galvo (Balor) presets and layout |
| [13-network-remote-access.md](13-network-remote-access.md) | Telnet / web / TCP-UDP map + `network/README.md` pointer |
| [14-console-quickref.md](14-console-quickref.md) | Curated console commands + how to discover more |
| [15-meerkat-local-changes.md](15-meerkat-local-changes.md) | Meerkat workspace edits to the clone (GUI, rules, changelog) |
| [16-mks-dlc32-board.md](16-mks-dlc32-board.md) | MKS DLC32 board specs and GRBL configuration with MeerK40t |
| [17-meerkat-dlc32-workflow.md](17-meerkat-dlc32-workflow.md) | Meerkat DLC32 400×285 workflow, device profile, Material Test / Manager |
| [18-meerk40t-ui-manual.md](18-meerk40t-ui-manual.md) | MeerK40t UI manual (all major windows, menus, workflow); optional PDF + screenshots |
| [19-dlc32-eeprom-settings.md](19-dlc32-eeprom-settings.md) | Confirmed GRBL EEPROM + homing/jog direction reference (Andre DLC32) |

## KB status (v1 “done”)

This round is **complete for a practical v1**: every major **driver family** you are likely to touch has a doc, plus **kernel**, **GUI**, **planner/spool**, **elements/I/O**, **network**, and a **console quick reference**.

**Intentionally not duplicated here (use upstream or code search):**

- Line-by-line **opcode lists** (`rdjob.py`, etc.) — link from [09-ruida.md](09-ruida.md) only.
- Full **Moshi / Newly / image / fill** subsystems — add `15-*.md` when you work on them.
- **Test** layout — `test/` and `testgui/` are self-describing; run `pytest` from clone root when needed.

## Depth choice

**v1 = overview + navigation + one planner deep dive.** New topics should be **new numbered files** so history stays clear.

## Source of truth

The running code wins over these notes. Clone path used when authoring:

`C:\Users\User\Ai Projects\meerkat\meerk40t`

Upstream: [https://github.com/meerk40t/meerk40t](https://github.com/meerk40t/meerk40t)
