# Rotary Pro (Meerkat fork v0.9.9035)

Enhanced **Y-motor-swap** rotary support for **GRBL / MKS DLC32** and other MeerK40t devices.

## What it does

| Input | Plugin uses it for |
|--------|------------------|
| **Outside diameter (mm)** | Circumference = π × D → wrap height |
| **Usable length (mm)** | Engravable zone along X (mug axis) |
| **Flat-bed Y $101** | Andre DLC32 gantry: **159.600** (restore value) |
| **Rotary Y steps/mm** | Different motor on Y driver — calibrated |
| **Auto Y wrap** | Sets effective Y-scale: circumference ÷ bed height |

**G-code:** still normal `G1 X… Y…`. X = head along object; Y = rotation.

## Steps calibration (two modes)

### Software compensate (default, recommended)

- EEPROM keeps flat-bed **`$101=159.600`**
- Driver multiplies Y by **`flat_$101 ÷ rotary_steps`**
- Safe if a flat-bed job runs with rotary mode accidentally left off (only wrap scale applies)

### Write $101 at job start (optional)

- Checkbox **Write $101 at job start**
- Before burn: `$101=<rotary>`
- After burn (or abort): `$101=<flat-bed>`
- Software compensation is disabled automatically
- Use only when you want panel jog to match rotary during the job

## Homing (DLC32 + Y swap)

| Action | Rotary mode on |
|--------|----------------|
| **Home** (G28) | Skipped if **Ignore Home** on (default) |
| **Home** right-click / panel | **$HX only** if **Physical home: X only** on; else blocked |
| **$HY** | **Never** — Y is the chuck |

## UI

**Device → Rotary-Settings** (or Rotary toolbar button).

- **Fit selection to rotary** — select artwork on the scene, then click the button (same as console `rotaryfit`). **Text:** scaled by font size (not matrix). If text already looks like a tiny round blob, **Undo** or delete it and add fresh text before fitting again.

Leave **Rotary-Mode active** **off** until the Y motor is wired to the chuck.

## Console workflow

```text
rotarysuggest 80 200 16 1
rotarycal 97.2
rotaryfit
rotary
```

1. Burn a **100 mm** wrap line at low power (set **Calibration test length**).
2. Measure → `rotarycal <measured>`
3. Select art → `rotaryfit`
4. `rotary` — check circumference and Y factor
5. Simulate → queue → burn

## Files

| Path | Role |
|------|------|
| `meerk40t/rotary/rotary.py` | Settings, console, view scale |
| `meerk40t/rotary/rotary_cam.py` | Math (circumference, steps, fit) |
| `meerk40t/grbl/driver.py` | Y compensation, $101 job hooks, homing |

## Limits

- **Chuck / Y-swap only** in this version (not DLC32 Z-roller mode).
- **Rasters** on rotary are slow; prefer vectors.
- **Touch panel homing** still runs full `$H` — avoid while on rotary.
