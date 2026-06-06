# Lihuiyu / M2–M3 (K40) — deeper dive

Extends [06-lihuiyu-k40-first-dive.md](06-lihuiyu-k40-first-dive.md) with registration detail and **device-local** commands.

---

## 1. Plugin (`meerk40t/lihuiyu/plugin.py`)

| Lifecycle | Behavior |
|-----------|----------|
| **`plugins`** | Loads `lihuiyu/gui/gui.py`. |
| **`invalidate`** | Requires **PyUSB** (`usb.core` / `usb.util`). If missing, plugin aborts with a printed message. |
| **`register`** | `provider/device/lhystudios` → **`LihuiyuDevice`**; friendly name **CO2-Laser (K40)**. **dev_info**: `m2-nano`, `m3-nano` (board `M2` / `M3`, labels, CO2 source). Optional **`load/EgvLoader`**, **`interpreter/lihuiyu`** if imports succeed. |
| **`preboot`** | Starts every persisted device section with prefix **`lhystudios`**: `service device start -p {d} lhystudios`. |

---

## 2. Device (`meerk40t/lihuiyu/device.py`)

- **`LihuiyuDevice`** — `Service` + **`Status`**: default **`extension`** `"egv"` (LaserDRW-style job files).
- **`LihuiyuDriver`** + **`LihuiyuController`** — same pattern as other families: driver implements spooler API; controller owns USB/pipe details.
- **`TCPOutput`** — optional TCP path (`tcp_connection.py`) for networked bridges.
- **Bed defaults** — e.g. width in device choices starts around **310mm** (see file for full choice list).

Many **@self.console_command** handlers live on the device (not only in kernel root). Highlights from grep:

- **Motion / job:** `start`, `hold`, `resume`, `estop` / `abort`
- **USB:** `usb_connect`, `usb_disconnect`, `usb_reset`, `usb_release`, `usb_abort`, `usb_continue`
- **Power / speed:** `power`, `device_speed`
- **Export:** `save_job` (with `input_type="plan"`)
- **`lhyserver`** — TCP server mode for external control (paired with **`main.py`** partial-kernel detection for substring `lhyserver`). Options include **quit** / shutdown current server (see `device.py` around the `lhyserver` definition).

For the exact signature and options, read the **`lhyserver`** block in `device.py` (lines ~1110+ in current tree).

---

## 3. Driver / controller / parser

| File | Role |
|------|------|
| `lihuiyu/driver.py` | Plot pipeline → board-specific machine units; implements spooler **`hold_work`**, laser job stepping. |
| `lihuiyu/controller.py` | USB bulk I/O, buffering, handshake with M2/M3. |
| `lihuiyu/parser.py` | Parses / assists **EGV** or related streams where applicable. |
| `lihuiyu/laserspeed.py` | Speed curve / PPI style conversions for CO2. |
| `lihuiyu/interpreter.py` | Registered as `interpreter/lihuiyu` when available. |
| `lihuiyu/loader.py` | **EgvLoader** when import succeeds. |

---

## 4. GUI (`meerk40t/lihuiyu/gui/`)

- **`gui.py`** — panel registration for this device family.
- **`lhycontrollergui.py`**, **`lhydrivergui.py`**, **`lhyoperationproperties.py`**, **`lhyaccelgui.py`** — configuration and operation UI.
- **`tcpcontroller.py`** — TCP-specific UI if used.

---

## 5. Hardware notes (from `dev_info` text)

- **M2 Nano** — common green “stock” K40 board; docstring in plugin cites common revision strings.
- **M3 Nano** — purple board family; hardware pause / PWM differences vs older cards; **M3Nano Plus** uses TMC steppers instead of A4988 (per in-code description).

---

## 6. Debugging checklist

1. **PyUSB** installed and device not grabbed by another driver (Windows: WinUSB/LibUSB setup per MeerK40t wiki).
2. **`usb_connect`** vs auto-connect behavior — read `device.py` startup paths.
3. **`lhyserver`** — port conflicts; only one listener per port.
4. **Board type** — M2 vs M3 presets affect PWM and pause behavior.

Cross-links: [07-planner-and-spooler.md](07-planner-and-spooler.md), [02-kernel-console-signals.md](02-kernel-console-signals.md).
