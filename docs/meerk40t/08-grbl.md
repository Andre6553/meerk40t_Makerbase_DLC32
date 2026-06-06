# GRBL driver (MeerK40t)

GRBL support targets **G-code serial (or TCP/WebSocket) controllers**: diode lasers, upgraded K40s on GRBL, FluidNC, Ortur, Longer Ray5, etc. The stack turns MeerK40t **CutCode** into **GRBL G-code** and streams it through a **controller** with buffering and status parsing.

---

## 1. Plugin entry

**File:** `meerk40t/grbl/plugin.py`

- **`lifecycle == "invalidate"`** — Requires **pyserial**; if missing, plugin fails load with a clear message.
- **`lifecycle == "register"`** — Registers:
  - `provider/device/grbl` → `GRBLDevice`
  - `driver/grbl` → `GRBLDriver`
  - `spoolerjob/grbl` → `GcodeJob`
  - `interpreter/grbl` → `GRBLInterpreter`
  - `emulator/grbl` → `GRBLEmulator`
  - `load/GCodeLoader` → `GCodeLoader`
  - Many **`dev_info/grbl-*`** presets (generic, FluidNC, K40 CO2, diode, Ortur, Longer, …) with default bed sizes, `source`, `require_validator`, etc.
- **`lifecycle == "preboot"`** — Starts every device section whose path begins with `grbl`:  
  `kernel.root(f"service device start -p {d} {prefix}\n")`

**GUI:** `lifecycle == "plugins"` returns `[gui.plugin]` from `meerk40t/grbl/gui/gui.py`.

---

## 2. Device vs driver

| Class | File | Role |
|--------|------|------|
| **GRBLDevice** | `grbl/device.py` | `Service` + `Status`: bed size, scale, connection policy (`permit_serial` / `permit_tcp` / `permit_ws`), **Spooler**, choices for preferences, device-level signals. |
| **GRBLDriver** | `grbl/driver.py` | Implements spooler-facing API: **`hold_work`**, **`job_start`** (if used), maps **LineCut**, **RasterCut**, etc. to G-code via **PlotPlanner**; tracks **pause**, buffer limits, WPos/MPos style state. |
| **GrblController** | `grbl/controller.py` | Low-level send/receive, line protocol, real-time vs streaming commands (read this for “ok” / “error:9” behavior). |

**`hold_work(priority)`** (`driver.py`): High **priority** (>0) jobs are not held (realtime path). Otherwise holds if **paused** or **controller buffer** over `max_buffer` when `limit_buffer` is enabled.

---

## 3. Connections

| Module | Role |
|--------|------|
| `grbl/serial_connection.py` | USB serial (common). |
| `grbl/tcp_connection.py` | Ethernet/TCP GRBL bridges. |
| `grbl/ws_connection.py` | WebSocket (e.g. some WiFi boards). |
| `grbl/mock_connection.py` | Testing without hardware. |

Device settings choose which path is active (see device choices in `device.py`).

---

## 4. Emulator / “GRBL server”

**GRBLControl** — `grbl/control.py`

- Opens a **TCP server** (default port **23**, telnet-friendly) via `module/TCPServer` named `grbl`.
- Instantiates **GRBLEmulator** bound to `root.device` and view matrix.
- Pipes `grbl/recv` → queue → emulator, emulator replies → `grbl/send`.

**Console:** command is **`grblcontrol`** (help text refers to “grblserver” conceptually). Options in `plugin.py`: `port`, `verbose`, `quit`; remainder `stop`/`quit` stops the control instance.

`main.py` treats both **`grblserver`** and **`grblcontrol`** as substrings that can imply **partial kernel** mode when passed with `-e` (alongside other servers).

**`grblmock`** — separate console command starting **`grblmock`** TCP server: minimal ok/status responses for protocol testing (`plugin.py`).

---

## 5. G-code job type

**GcodeJob** — `grbl/gcodejob.py`  
Alternative spooler job type registered as `spoolerjob/grbl` (used where raw G-code sequences are managed differently from generic `LaserJob`—read file when debugging G-code-only paths).

**GRBLInterpreter** — `grbl/interpreter.py`  
Used for interpreting / assisting G-code flows registered as `interpreter/grbl`.

---

## 6. GUI

Under `meerk40t/grbl/gui/`:

- `grblcontroller.py`, `grblconfiguration.py`, `grblhardwareconfig.py`, `grbloperationconfig.py` — device UI.
- **ESP3D** helpers: `esp3dconfig.py`, `esp3dfilemgr.py` (postboot commands like `esp3d_config` registered from `plugin.py`).

---

## 7. GRBL-specific debugging tips

1. **Alarm / lock** — Controller state must allow streaming; driver/controller handle `$X`, `$H` style flows where implemented—confirm in `controller.py` and device choices.
2. **Buffer stalls** — `hold_work` + `limit_buffer` / `max_buffer`: watch for “machine not taking data” symptoms.
3. **Wrong board flavor** — Use correct **`dev_info`** preset (e.g. **FluidNC** `flavor` attr) so validation and defaults match firmware.
4. **Line endings** — `GRBLDriver` uses service setting **`line_end`** (`CR` vs `LF`) via `_set_line_end`.

---

## 8. Reading order (GRBL)

1. `grbl/plugin.py` — presets you care about (e.g. `grbl-k40`, `grbl-fluidnc`).
2. `grbl/device.py` — spooler attachment, choices, connection startup.
3. `grbl/driver.py` — `hold_work`, plot pipeline, G-code emission.
4. `grbl/controller.py` — wire protocol and replies.
5. `grbl/serial_connection.py` (or tcp/ws) — physical link.

Cross-link: [07-planner-and-spooler.md](07-planner-and-spooler.md) for how **`LaserJob.execute(driver)`** invokes the driver.
