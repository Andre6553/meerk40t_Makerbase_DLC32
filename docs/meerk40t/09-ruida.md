# Ruida driver (MeerK40t)

Ruida support covers **DSP-style CO2 controllers** that speak the **Ruida binary protocol**, **`.rd` file loading**, and—importantly—**emulation** so external programs (e.g. LightBurn talking “Ruida UDP”) can target MeerK40t, which then turns traffic into **local laser jobs**.

The module docstring on **`RuidaDevice`** states the design angle: not only “talk to Ruida ASIC,” but **emulate** Ruida traffic into **cutcode** and ingest **RD** files similarly (`ruida/device.py`).

---

## 1. Plugin entry

**File:** `meerk40t/ruida/plugin.py`

- **`lifecycle == "register"`**:
  - `provider/device/ruida` → `RuidaDevice`
  - `dev_info/ruida-beta` — K50/K60-style preset (priority `-1`, “tested on Linux” note in friendly text).
  - `spoolerjob/ruida` → **`RDJob`** (Ruida-specific spooler job)
  - `load/RDLoader` → **`RDLoader`** (`.rd` import)
  - `emulator/ruida` → **`RuidaEmulator`**
  - **`ruidacontrol`** console command — starts **`RuidaControl`** (see below).

- **`lifecycle == "preboot"`** — Starts services for every device section beginning with `ruida` (same pattern as GRBL).

- **`lifecycle == "plugins"`** — Loads `ruida/gui/gui.py`.

---

## 2. Device vs driver vs controller

| Class | File | Role |
|--------|------|------|
| **RuidaDevice** | `ruida/device.py` | `Service` + `Status`: bed, scale, power/speed display prefs, **Spooler**, `.rd` extension, **RuidaSession** / transport errors. |
| **RuidaDriver** | `ruida/driver.py` | **PlotPlanner** + **RuidaController**; per-device channels `{safe_label}/send` and `{safe_label}/recv`; **`hold_work`** = paused for priority ≤ 0; **`job_start` / `job_finish`** no-ops here. |
| **RuidaController** | `ruida/controller.py` | Parses inbound packets, coordinates with **RDJob** state machine. |

Driver wires **`recv`** → `controller.recv` so incoming UDP/USB data feeds the protocol decoder.

---

## 3. Transports

| Module | Role |
|--------|------|
| `ruida/udp_connection.py` / `udp_transport.py` | Typical **UDP** (RDWorks / LightBurn style ports). |
| `ruida/tcp_connection.py` | TCP where used. |
| `ruida/usb_transport.py` | USB transport layer. |
| `ruida/serial_connection.py` | Serial where applicable. |
| `ruida/mock_connection.py` | Tests without hardware. |

**RuidaSession** — `ruida/ruidasession.py` — Session-level state for a connection.

---

## 4. RDJob and rdjob.py

**`RDJob`** (`ruida/rdjob.py`) is large: **opcode constants** (e.g. `MOVE_ABS_XY`, `CUT_ABS_XY`, interface pad opcodes), parsers **`parse_commands`**, **`parse_mem`**, machine status enums, and logic to translate Ruida program bytes into driver operations / cut primitives.

**Registration:** `kernel.register("spoolerjob/ruida", RDJob)` so the spooler can run Ruida-shaped job objects when used on this device path.

For “what does opcode 0x88 mean?” — read **`rdjob.py`** tables and handlers (authoritative).

---

## 5. Emulator + `ruidacontrol`

**RuidaEmulator** — `ruida/emulator.py`

- Listens for **Ruida protocol** traffic, maintains **magic** byte (default `0x88`, comment mentions `0x11` for 634XG), **swizzle** tables, **`RDJob`** instance tied to **`device.driver`**.
- **`process_commands`**, **`checksum_write`**, **`realtime_write`** — entry points from UDP wiring (see `RuidaControl.connect_emulator_to_udp`).

**RuidaControl** — `ruida/control.py`

- **`open_udp_to_mk`** — UDP servers **`rd2mk`** port **50200**, **`rd2mk-jog`** port **50207** (program vs jog channels).
- **`open_udp_to_laser`** — **`mk2lz`** port **40200**, **`mk2lz-jog`** port **40207**, optionally forwarding to **`man_in_the_middle`** IP (real laser).
- **`connect_man_in_the_middle`** — Bridges rd2mk ↔ mk2lz channels (proxy mode).
- **`connect_emulator_to_udp`** — Feeds **`rd2mk/recv`** into **`emulator.checksum_write`**, replies **`emulator.reply`** → **`rd2mk/send`**; jog port uses **`realtime_write` / `realtime`**.

**Console: `ruidacontrol`**

Options (`plugin.py`): `verbose`, `quit`, `jogless`, `man_in_the_middle`, `bridge` (LB2RD bridge protocol).  
Creates **`RuidaControl(root)`**, registers as `ruidacontrol` on `root.device`, calls **`start(...)`**. `quit` tears it down.

`main.py` includes **`ruidacontrol`** in server-style `-e` substrings for partial kernel behavior.

---

## 6. Loader

**RDLoader** — `ruida/loader.py`  
Registered `load/RDLoader` for importing **`.rd`** into the element/plan world (details in file).

---

## 7. GUI

`ruida/gui/`: **`ruidacontroller.py`**, **`ruidaconfig.py`**, **`ruidaoperationproperties.py`**, **`gui.py`** — device configuration and operation property panels.

---

## 8. Practical notes

1. **Emulation vs direct DSP** — Much community value is **UDP emulation** (LightBurn → MeerK40t → USB Lihuiyu/GRBL/etc.), not only driving a physical Ruida card. Trace **`RuidaControl.start`** and **`connect_emulator_to_udp`** for your scenario.
2. **Magic byte** — Wrong magic → garbled decode; emulator can adjust (`set_magic` in emulator).
3. **Linux note** — `dev_info/ruida-beta` extended info mentions Linux testing; Windows may work but treat edge cases as “verify locally.”
4. **Signal updates** — `RuidaDriver` sets `_signal_updates = False` with a comment about cursor/position sync—UI position may differ from internal model during some states.

---

## 9. Reading order (Ruida)

1. `ruida/plugin.py` — registration + `ruidacontrol` options.
2. `ruida/device.py` — service shape, spooler, session.
3. `ruida/control.py` — UDP ports, MITM bridge, emulator hookup.
4. `ruida/emulator.py` — command entry, magic, RDJob construction.
5. `ruida/rdjob.py` — opcodes and decode (reference, not linear read).
6. `ruida/driver.py` — how cut operations become sends.

Cross-links: [07-planner-and-spooler.md](07-planner-and-spooler.md), [06-lihuiyu-k40-first-dive.md](06-lihuiyu-k40-first-dive.md) (if your downstream device is K40).
