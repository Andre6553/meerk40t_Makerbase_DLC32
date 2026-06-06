# Balormk / JCZ galvo (fiber, CO2, UV, MOPA)

**EZCad2-compatible** galvo controllers (JCZ / BJJCZ family), often **USB**, with optional **MOPA** pulse-width features.

---

## 1. Plugin (`meerk40t/balormk/plugin.py`)

| Lifecycle | Behavior |
|-----------|----------|
| **`plugins`** | Loads **`balormk/galvo_commands.py`** and **`balormk/gui/gui.py`**. |
| **`invalidate`** | Same as Lihuiyu: requires **PyUSB**; fails load if missing. |
| **`register`** | `provider/device/balor` → **`BalorDevice`**; friendly **Fibre-Laser**. Multiple **dev_info** presets: **`balor-fiber`**, **`balor-fiber-mopa`** (`pulse_width_enabled=True`), **`balor-co2`**, **`balor-uv`**. |
| **`preboot`** | Starts persisted sections with prefix **`balor`** (note: uses `kernel.settings.section_startswith` in this file—same intent as other drivers). |

---

## 2. Device package

Primary implementation lives under **`meerk40t/balormk/`** (e.g. `device.py`, `driver.py`, USB transport). The upstream **`balormk/README.md`** in the repo gives additional architecture notes for contributors.

**Galvo-specific concerns:**

- **Field size** and **correction files** (if supported in your build).
- **MOPA** — separate preset enables pulse width path in settings.
- **Source type** — `fiber` vs `co2` vs `uv` changes defaults and labels, not necessarily low-level USB VID/PID handling.

---

## 3. GUI

`meerk40t/balormk/gui/` — configuration windows, device controller panels, and any galvo-specific property sheets.

---

## 4. When to read this path

- Fiber / galvo marking machines using **JCZ** boards.
- Not used for **K40 M2 Nano** (that is **Lihuiyu** — [10-lihuiyu-deep.md](10-lihuiyu-deep.md)).

Cross-link: [04-drivers-and-plugins.md](04-drivers-and-plugins.md) for full internal plugin list.
