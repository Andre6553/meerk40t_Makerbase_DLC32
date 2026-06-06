# Console quick reference (curated)

Not a complete catalog—MeerK40t registers **hundreds** of commands across plugins. This lists **high-value entry points** and where they are defined so you can search deeper.

Convention: many commands are chained: **`plan0 copy ...`**, **`spool0`** style—see [07-planner-and-spooler.md](07-planner-and-spooler.md).

---

## 1. Meta / help

| Command | Where to look |
|---------|----------------|
| **`help`** | Kernel help system (try `help` and topic args in running app). |
| **`quit` / `exit` / `shutdown`** | Registered from `gui/plugin.py` (closes GUI). |

---

## 2. Planner & spool

| Command | Source file | Notes |
|---------|-------------|--------|
| **`plan`**, **`plan<N>`** | `core/planner.py` | Default plan index; subcommands `copy`, `copy-selected`, `clear`, `preprocess`, `validate`, `blob`, `preopt`, `optimize`, `spool`, … |
| **`list-plans`** | `core/planner.py` | Lists plans + stage text. |
| **`spool`**, **`spool<?> list`**, **`clear`** | `core/spoolers.py` | Enqueue laser job from plan; manage queue. |
| **`send`** (on spooler) | `core/spoolers.py` | Dispatch named plan helper commands. |

---

## 3. Devices

| Command / pattern | Source | Notes |
|-------------------|--------|--------|
| **Device listing** | `device/basedevice.py` | Boot registers helpers; search **`display_devices`** / `device` in same file. |
| **Lihuiyu `usb_*`, `lhyserver`, `power`, …** | `lihuiyu/device.py` | Device-scoped console. |
| **`viewport_update`** | `device/basedevice.py` | Hidden; refresh realization. |

---

## 4. Network servers

| Command | Source | Notes |
|---------|--------|--------|
| **`consoleserver`** | `network/console_server.py` | Telnet kernel console. |
| **`webserver`** | `network/web_server.py` | HTTP UI. |

---

## 5. Driver emulators / bridges

| Command | Source | Notes |
|---------|--------|--------|
| **`grblcontrol`** | `grbl/plugin.py` | TCP GRBL emulator (often port 23). |
| **`grblmock`** | `grbl/plugin.py` | Minimal mock for tests. |
| **`ruidacontrol`** | `ruida/plugin.py` | Ruida UDP emulation / MITM options. |

---

## 6. Console UI pane

| Command | Source | Notes |
|---------|--------|--------|
| **`cls` / `clear`** | `gui/consolepanel.py` | Clear rich console view. |
| **`console_font`** | `gui/consolepanel.py` | Font preferences. |

---

## 7. How to discover more

1. In repo: **`rg "console_command"` meerk40t`** (limit by directory: `meerk40t/grbl`, etc.).
2. In running MeerK40t: type **`help`** and explore subtopics.
3. Prefer **device context**: prefix with device path if your command is registered on `self` of a `Service`.

---

## 8. Incremental expansion of this doc

Suggested future sections (add when you need them):

- **Elements** verbs (`element`, `operation`, …) — grep `core/elements/elements.py`.
- **Image** / **camera** — `image/`, `camera/` plugins.
- **Rotary / cylinder** — `rotary/`, `cylinder/` plugins.

When a section grows past ~200 lines, split into **`14a-…`**, **`14b-…`**.
