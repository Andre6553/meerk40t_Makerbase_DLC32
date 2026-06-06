# Network — remote console, web, TCP/UDP

MeerK40t can expose **telnet**, **UDP**, and **HTTP** interfaces so other programs (or humans on the LAN) can run **kernel console** commands and inspect spoolers.

**Authoritative detail:** upstream `meerk40t/network/README.md` in the clone (long document). This page is a **short map** so you know where to look.

---

## 1. Plugin hub (`meerk40t/network/kernelserver.py`)

On `lifecycle == "plugins"` returns sub-plugins:

- `tcp_server.plugin`
- `udp_server.plugin`
- `web_server.plugin`
- `console_server.plugin`

`invalidate` returns `True` (module always considered for lifecycle; actual servers start on demand).

---

## 2. Console server (`network/console_server.py`)

**Command:** **`consoleserver`**

- Opens **`module/TCPServer`** named **`console-server`** (default port from root setting **`default_telnet_port`**, typically **23**).
- Options: **`port`**, **`silent`**, **`suppress`** (hide `>>` prompt), **`quit`** (shutdown).
- Incoming lines are handed to the kernel with **GUI thread handover** (see `exec_command` in file) so console side effects stay safe for wx.

---

## 3. Web server (`network/web_server.py`)

**Command:** **`webserver`** (see upstream README; default port setting **`default_webserver_port`**, often **2080**).

Provides HTML UI: spooler table, device info, form to post console commands.

---

## 4. TCP / UDP generic servers

- **`module/TCPServer`** — used by GRBL/Ruida/Lihuiyu emulators and **console-server** with different **channel names** (`{name}/send`, `{name}/recv`).
- **`module/UDPServer`** — Ruida paths use UDP extensively (`ruida/control.py`); generic UDP plugin exists for other patterns.

---

## 5. Security (from upstream README)

Servers historically bind in a way that may expose them on **all interfaces**. Treat as **trusted network only** unless you add firewall rules. There is **no built-in authentication** in this stack.

---

## 6. `main.py` interaction

Substrings like **`webserver`** in `-e` commands can trigger **partial kernel** startup (alongside `lhyserver`, `grblserver`, `grblcontrol`, `ruidacontrol`, etc.).

---

## 7. Reading order

1. `network/README.md` (in clone).
2. `network/console_server.py` — telnet path.
3. `network/web_server.py` — HTTP path.
4. Driver-specific server docs: [08-grbl.md](08-grbl.md), [09-ruida.md](09-ruida.md), [10-lihuiyu-deep.md](10-lihuiyu-deep.md).
