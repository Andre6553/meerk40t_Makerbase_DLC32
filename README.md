# meerk40t_Makerbase_DLC32

**Andre van der Westhuizen** — personal workspace for running [MeerK40t](https://github.com/meerk40t/meerk40t) with a **Makerbase MKS DLC32** controller on a **30×40 cm, 60 W CO2 laser**.

> **Important:** This is **not** a classic **K40** (the small ~300×200 mm stock machine with an M2 Nano board). It is a **3040-class** engraver/cutter: roughly **300×400 mm** frame, **60 W** tube, **Cloudray-style PSU**, **NEMA 17** gantry motors, and an **AC gear-motor Z axis** that stays on the machine’s physical up/down switches — **not** driven by the DLC32.

**GitHub:** https://github.com/Andre6553/meerk40t_Makerbase_DLC32

---

## What this repository is

This repo holds everything **around** the laser workflow except the MeerK40t Python source itself:

| Included here | Purpose |
|---------------|---------|
| **`docs/meerk40t/`** | In-depth knowledge base: DLC32 setup, workflows, UI manual, changelog |
| **`.cursor/rules/`** | Cursor AI rules (EEPROM reference, backup policy, `/settings` annotation) |
| **`Firmware Settings/`** | Canonical GRBL **`$$`** dump from the live board |
| **`scripts/`** | Wi‑Fi wake script, manual extracts, helper images |
| **`MKS dlc32/`**, **`MKS-DLC32-*`** | Makerbase board and firmware reference (upstream downloads) |
| **`images/`** | Screenshots for the local UI manual |
| **`run-meerk40t-dev.bat`** | Windows launcher (wake board → activate venv → start MeerK40t) |

The **MeerK40t application code** lives in a **separate fork** (see below). After cloning this workspace, you clone the fork into a `meerk40t/` folder beside these files.

---

## Related repositories

| Repository | Contents |
|------------|----------|
| **[meerk40t_Makerbase_DLC32](https://github.com/Andre6553/meerk40t_Makerbase_DLC32)** (this repo) | Docs, rules, EEPROM, scripts, reference material |
| **[Andre6553/meerk40t](https://github.com/Andre6553/meerk40t)** | MeerK40t **source fork** with all local code changes |
| **[meerk40t/meerk40t](https://github.com/meerk40t/meerk40t)** | Upstream MeerK40t (baseline this fork builds on) |

Upstream MeerK40t already supports GRBL devices. This project adds **DLC32-specific defaults**, **Wi‑Fi wake/connect**, **sequential homing**, **coordinate fixes**, and several **GUI improvements** tuned on Andre’s machine.

---

## Hardware overview

### The machine (3040, 60 W — not a K40)

| Item | Detail |
|------|--------|
| **Class** | ~**30×40 cm** CO2 laser (often sold as **3040** / **6040-style** frame) |
| **Tube** | **60 W** CO2 |
| **PSU** | **Cloudray M60** (or equivalent) — **`WP`** water-protect input |
| **Motion** | **NEMA 17** steppers on X and Y (A4988 drivers on the DLC32) |
| **Z axis** | **220 V AC gear motor** on the chassis switch — **not** connected to the DLC32 |
| **Safety** | **Water flow sensor** wired to PSU **`WP`** → **`G`**. No flow = no HV, independent of GRBL |
| **Controller upgrade** | Stock nano/8-bit board replaced with **MKS DLC32** (ESP32, GRBL 1.1h, Wi‑Fi, touch panel) |

The MeerK40t device profile is named **“K40 CO2 — MKS DLC32”** in code — that name is **legacy wording** from the profile template. The **bed size and EEPROM values below match this 3040 machine**, not a stock K40.

### MKS DLC32 board

| Item | Detail |
|------|--------|
| **MCU** | ESP32-WROOM-32U @ 240 MHz |
| **Firmware** | Grbl_Esp32 / **GRBL 1.1h** with **ESP32-WEB** (browser UI + TCP) |
| **Connection to PC** | **Wi‑Fi TCP port `8080`** (not telnet port 23) or **USB serial** (CH340) |
| **Default IP** | `192.168.10.90` (set a **DHCP reservation** on your router) |
| **Touch panel** | TS35 — jog, power test, hard home buttons (see homing notes) |
| **Laser PWM** | **`$32=1`** laser mode required |

More board detail: [`docs/meerk40t/16-mks-dlc32-board.md`](docs/meerk40t/16-mks-dlc32-board.md)

### Limit switches and home position

Only **two** mechanical limits are installed — both at the **top-left** corner (off the bed):

```text
  [X− switch] [Y+ switch]     ← home corner (top-left)
        ┌─────────────────────────┐
        │      WORK BED           │
        │                         │
        │              [head]     │  ← far corner = max travel, NO switches
        └─────────────────────────┘
```

| Switch | Header | Role |
|--------|--------|------|
| **X home** | **X−** | X homes toward the **left** |
| **Y home** | **Y+** | Y homes toward the **top** |

**Unused limit inputs must be jumpered GND–S** so GRBL does not see false triggers:

| Header | Andre’s machine |
|--------|-----------------|
| **X+**, **Y−**, **Z±**, **Probe** | **Jumper GND–S** (no switch) |

After successful homing: **`MPos ≈ 0, 0, 0`**. Moving **into the bed**: **X+** (toward **405 mm**), **Y−** (toward **−285 mm**).

### Motor drivers (A4988)

| Axis | Motor | DIP | Target **Vref** | GRBL steps/mm |
|------|-------|-----|-----------------|---------------|
| **X** | 17HW3406N-16AD-Y | 1/16 microstep | **~0.80 V** (~1.0 A) | **`$100=157.21`** (calibrated with ruler) |
| **Y** | 17HW4410N-03AD-Z | 1/16 microstep | **~0.80 V** (~1.0 A) | **`$101=159.60`** |

Factory Vref is often too low → stutter at speed → can look like limit or position faults. Measure Vref at the pot vs **GND**, motor unplugged, **24 V on**.

**Power supply:** use a solid **24 V ≥ 10 A** supply for the DLC32 + two NEMA 17s at ~0.8 V Vref. Undersized PSUs cause **brownout reboots** (board shows `Grbl 1.1h` again mid-cut).

### Cloudray PSU and laser enable

| DLC32 | PSU |
|-------|-----|
| **S** (spindle/laser) | **IN** |
| **TTL GND** | **G** |
| — | **`WP`** ← flow sensor (other wire to **G**) |

Do **not** use the PSU **V** pin on the S-TTL-V connector for Cloudray wiring.

---

## GRBL EEPROM setup (Makerbase DLC32)

**Authoritative file:** [`Firmware Settings/settings`](Firmware%20Settings/settings)  
**Annotated copy:** [`Firmware Settings/settings-annotated.md`](Firmware%20Settings/settings-annotated.md)  
**Full reference:** [`docs/meerk40t/19-dlc32-eeprom-settings.md`](docs/meerk40t/19-dlc32-eeprom-settings.md)

### Key values (Andre’s board, 2026-06)

| Setting | Value | Meaning |
|---------|-------|---------|
| **`$130`** | **405** | X max travel (mm) |
| **`$131`** | **285** | Y max travel (mm) |
| **`$32`** | **1** | Laser mode (required) |
| **`$110` / `$111`** | **5500 / 5000** | X/Y max rate (mm/min) — **~92 / ~83 mm/s** caps |
| **`$30` / `$31`** | **1000 / 50** | Spindle/laser PWM range |
| **`$3`** | **0** | Step direction invert — **jog + touch panel** (do not change if jog is correct) |
| **`$23`** | **1** | Homing direction invert — **homing only** (X inverted; Y correct) |
| **`$22`** | **1** | Homing enabled |
| **`$20` / `$21`** | **0 / 0** in test snapshot | Soft/hard limits — enable **`$20=1`** and **`$21=1`** when travel is verified |
| **`$120` / `$121`** | **500 / 400** | X/Y acceleration (mm/s²) — tune down if motors buzz or skip steps |

### Homing procedure (critical)

**Never use `$H`** (both axes at once) on this machine — it often stops ~50 mm before the switches with **ALARM:1**.

**Always:**

1. **`$X`** — clear alarm  
2. **`?`** — **`Pn:` must be empty** at rest  
3. **`$HY`** — wait for `ok`  
4. **`$HX`** — wait for `ok`  
5. **`?`** — expect **`MPos:0.000,0.000,0.000`**

MeerK40t (with this fork): enable **Has endstops** + **Sequential homing** → the **Home** button sends **`$HY`** then **`$HX`**.

**Two different direction settings:**

- **`$3`** = everyday jog, cuts, touch-screen arrows  
- **`$23`** = homing search direction only  

If jog is correct, **only change `$23`** to fix homing — not **`$3`**.

---

## MeerK40t device profile

When adding a device in MeerK40t, use:

**Device type:** `K40 CO2 — MKS DLC32 (405×285 mm)`  
Console: `device add grbl-dlc32-k40-400`

| Setting | Value | Why |
|---------|-------|-----|
| **Bed** | **405 × 285 mm** | Match **`$130` / `$131`** |
| **Home corner** | **top-left** | Switches at top-left |
| **Flip Y** | **On** | Board **MPos Y = 0** at top; into bed is **negative Y** |
| **Swap XY** | **Off** | Touch panel X/Y matches MeerK40t |
| **Interface** | **TCP** `192.168.10.90:8080` | DLC32 ESP32-WEB data port (not 23) |
| **Reset on connect** | **On** | |
| **Post-connection delay** | **500 ms** | Helps Wi‑Fi stability |
| **Has endstops** | **On** | |
| **Sequential homing** | **On** | **`$HY` then `$HX`** |

**Before every session:** Home (`$HY` / `$HX`), then jog. If you see **ALARM:2** on Y jog, check **Flip Y** and **Home corner** — see workflow doc §5.

Workflow checklist: [`docs/meerk40t/17-meerkat-dlc32-workflow.md`](docs/meerk40t/17-meerkat-dlc32-workflow.md)

---

## Changes from upstream MeerK40t

All code changes are in **[Andre6553/meerk40t](https://github.com/Andre6553/meerk40t)**. Summary by area:

### GRBL / MKS DLC32 driver

| Change | Files (approx.) | What it does |
|--------|-------------------|--------------|
| **DLC32 device profile** | `grbl/plugin.py`, `grbl/device.py` | Bed 405×285, TCP `:8080`, macros, sequential homing defaults |
| **Sequential homing** | `grbl/driver.py`, `device.py`, navigation | **Home** runs **`$HY`** then **`$HX`** instead of **`$H` / G28** |
| **TCP port 8080** | `grbl/tcp_connection.py`, `plugin.py` | Auto-probes **8080** then 23; matches ESP32-WEB |
| **Wi‑Fi wake before connect** | `grbl/tcp_connection.py`, `scripts/wake-mks-dlc32.ps1` | HTTP ping wakes ESP32; retries TCP; removed 8 s read timeout that dropped Wi‑Fi mid-`$$` |
| **MPos sync** | `grbl/controller.py` | MeerK40t position tracks board after touch-panel moves |
| **Y jog / Flip Y fix** | `grbl/driver.py`, `controller.py` | Confined jog uses bed coords; warns if Flip Y off with negative MPos Y |
| **Confined jog crash fix** | `grbl/driver.py` | Parses `"405mm"` bed strings correctly |
| **Override direction fix** | `grbl/driver.py`, `laserpanel.py` | GRBL **0x9A/0x9B** power override matches GRBL 1.1; 5% steps + typed Set |

### GUI / workflow

| Change | What it does |
|--------|--------------|
| **Laser-Control job progress** | Real progress bar from `steps_done/steps_total` (was stuck at “No job running”) |
| **Parameter-Test → Spooler** | **Queue to Spooler** button; shared queue helper; **Hold** fix |
| **Unassigned elements warning** | Warns before queue if inner shapes have no Cut op |
| **Tree double-click → Parameter-Test** | Double-click Cut/Engrave op opens power/speed test, not generic Properties |
| **Material dropdown on Tree** | Quick-load Material Manager presets |
| **Material Manager delete fix** | No crash when deleting categories |
| **Keyboard Delete** | Delete / numpad Del matches ribbon Delete on canvas |
| **Bed movement limit default** | “Limit laser movement to bed size” on at startup; warning if disabled |
| **Simulation cancel** | **Stop calculating** during preview build |
| **Tips persistence** | “Show tips at startup” saves immediately |
| **Ribbon delayed tooltips** | Long-hover help on ribbon buttons |
| **Scene startup crash fix** | No crash on 0×0 window before layout |
| **Move laser head here** | Right-click the scene grid → move head to click position (`move_absolute`; same coords as **Relocate** tool) |

### EEPROM docs

| Change | What it does |
|--------|--------------|
| **`/settings` in Cursor** | Regenerates [`Firmware Settings/settings-annotated.md`](Firmware%20Settings/settings-annotated.md) from the live `$$` dump |
| **Annotated EEPROM table** | Quick reference + per-setting descriptions for Andre’s board (bed, homing, speeds, laser mode) |

Full dated changelog: [`docs/meerk40t/15-meerkat-local-changes.md`](docs/meerk40t/15-meerkat-local-changes.md)

---

## Getting started

### 1. Clone this workspace

```powershell
git clone https://github.com/Andre6553/meerk40t_Makerbase_DLC32.git
cd meerk40t_Makerbase_DLC32
```

### 2. Clone the MeerK40t fork

```powershell
git clone https://github.com/Andre6553/meerk40t.git meerk40t
cd meerk40t
python -m venv .venv
.\.venv\Scripts\pip install -r requirements.txt
cd ..
```

### 3. Local secrets (optional)

```powershell
copy .env.example .env
# Edit .env locally — router login, etc.  NEVER commit .env
```

### 4. Network the DLC32

1. Connect the board to your Wi‑Fi (ESP32-WEB UI or phone app).  
2. Set a **DHCP reservation** for the board (default **`192.168.10.90`**).  
3. Confirm in a browser: `http://192.168.10.90/`  
4. Only **one TCP client at a time** — close ESP32-WEB or other apps before MeerK40t connects.

### 5. Run MeerK40t

Edit paths in `run-meerk40t-dev.bat` if your folder is not  
`C:\Users\User\Ai Projects\meerkat`, then:

```powershell
.\run-meerk40t-dev.bat
```

The launcher runs **`wake-mks-dlc32.ps1`** (HTTP + TCP **8080** check), activates the venv, and starts MeerK40t.

**Manual wake:**

```powershell
powershell -File scripts\wake-mks-dlc32.ps1 -Ip 192.168.10.90
```

### 6. First cut checklist

1. Water chiller running → flow sensor closes **`WP`**.  
2. Focus Z with the **physical switch** (not MeerK40t).  
3. Connect device (Wi‑Fi or USB).  
4. **Home** (`$HY` → `$HX`).  
5. **Tools → Parameter-Test** on scrap → **Queue to Spooler** → **Start**.  
6. Save winning speeds/powers in **Material Manager**.

---

## Documentation index

Start here for deep dives:

| Doc | Topic |
|-----|--------|
| [`docs/meerk40t/README.md`](docs/meerk40t/README.md) | Knowledge base index |
| [`docs/meerk40t/15-meerkat-local-changes.md`](docs/meerk40t/15-meerkat-local-changes.md) | Code changelog |
| [`docs/meerk40t/16-mks-dlc32-board.md`](docs/meerk40t/16-mks-dlc32-board.md) | Board specs, wiring, Vref, limits |
| [`docs/meerk40t/17-meerkat-dlc32-workflow.md`](docs/meerk40t/17-meerkat-dlc32-workflow.md) | Day-to-day workflow, alarms, Wi‑Fi |
| [`docs/meerk40t/19-dlc32-eeprom-settings.md`](docs/meerk40t/19-dlc32-eeprom-settings.md) | Full **`$$`** reference |
| [`docs/meerk40t/18-meerk40t-ui-manual.md`](docs/meerk40t/18-meerk40t-ui-manual.md) | Illustrated UI manual |

---

## Safety notes

- **CO2 laser:** eye protection, enclosure, interlocks, fire watch.  
- **Water flow:** never bypass **`WP`** permanently.  
- **Homing:** use **`$HY` then `$HX`** — not **`$H`**.  
- **Touch panel “weak/strong beam”:** GRBL laser mode turns PWM off when motion stops — brief flash is normal; use MeerK40t **Pulse** for a controlled test.  
- **Wi‑Fi:** prefer **USB** for long jobs until the link is proven stable.  
- **Limits:** enable **`$20=1`** / **`$21=1`** only after homing and travel are verified.

---

## License and upstream

MeerK40t is **[GPL-3.0](https://github.com/meerk40t/meerk40t/blob/main/LICENSE)**. This workspace’s docs and scripts are Andre’s personal notes; the code fork remains GPL-3.0 as derived from upstream.

**Author:** Andre van der Westhuizen — [Arline Photography](https://www.arlinephotography.co.za) — Mossel Bay, South Africa
