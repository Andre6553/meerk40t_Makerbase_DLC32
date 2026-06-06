# Meerkat workflow — MKS DLC32 K40 (400×285 mm)

Local learning-phase checklist for Andre’s CO2 machine with **MKS DLC32**, **MeerK40t (meerkat)**, and **ESP32-WEB**.

See also: [19-dlc32-eeprom-settings.md](19-dlc32-eeprom-settings.md) (confirmed EEPROM), [16-mks-dlc32-board.md](16-mks-dlc32-board.md), [15-meerkat-local-changes.md](15-meerkat-local-changes.md).

---

## 1. Device profile in MeerK40t

When **adding a new device** (or duplicating for a clean setup):

1. **Device → Add** (or console `device add grbl-dlc32-k40-400`)
2. Pick **K40 CO2 — MKS DLC32 (400×285 mm)** (`dev_info/grbl-dlc32-k40-400`)

Defaults applied:

| Setting | Value |
|---------|--------|
| Bed | **400 mm × 285 mm** (match board **`$130`/`$131`**) |
| **Home corner** | **top-left** (home at top of bed) |
| **Flip Y** | **On** (required — board Y is 0 at top, negative into bed) |
| **Swap XY** | Off (Andre machine — touch X/Y matches MeerK40t) |
| Interface | **TCP** `192.168.10.90:8080` (edit IP if yours differs) |
| **Reset on connect** | On |
| **Has endstops** | **On** (wired at top-left) |
| **Sequential homing** | **On** (`$HY` then `$HX` — not `$H`) |
| GRBL macros | Clear alarm, work zero, status, `$$`, `$I` |

Existing devices are **not** auto-migrated — adjust **GRBL-Configuration** manually or add a new profile.

---

## 2. Parameter Test (power/speed card) — use once per material

**No extra meerkat code** — built into MeerK40t. Menu: **Tools → Laser-Tools → Parameter-Test** (opens the **Parameter-Test** window).

**Important:** **Create Pattern** only builds operations and shapes on the **Scene**. It does **not** send anything to the spooler. You need a second step (below).

1. Connect to the board (Wi‑Fi or USB).
2. Open **Parameter-Test** as above.
3. Set pattern size to fit your bed (e.g. **400 × 285 mm** or a smaller patch in the corner).
4. Choose operation type (**Cut** or **Engrave**), power/speed ranges, grid size.
5. Click **Create Pattern** → confirm **Yes** (replace scene) or **No** (keep existing). Check the **Operations** tree: many ops with assigned squares should appear.
6. **Queue the job** (pick one):
   - **Parameter-Test** → **Queue to Spooler** (rebuilds plan from the grid; best after **Create Pattern**), or
   - **Laser** tab → **Arm** → **Start** (same pipeline; turn **Hold** off unless you mean to re-spool an old plan), or
   - **Simulate** → wait until **Send to Laser** is enabled (not stuck on **Calculating**) → **Send to Laser**.
7. If **Preferences → threaded mode** is on, wait **5–15 s** after queue/Start — planning runs in the background (**Thread Info** may open).
8. **Job Spooler** (often opens automatically) → **Start** the job on **cardboard or scrap MDF**; note the best cells.
9. Save the template on the **Templates** tab if you repeat tests later.

**If the spooler stays empty:** device not connected, **Start** disabled (click **Arm** first), **Hold** on (re-spools an old plan without rebuilding — turn **Hold** off), background plan still running (wait / check **Thread Info**), Simulation opened *before* **Create Pattern**, or cut planning failed (popup / console: *Invalid plan - no 'blob' plan stage* / *Cut planning failed*).

Record winners in a notebook or in **Material Manager** (below).

---

## 3. Material Manager — 2–3 starter presets (manual)

Create presets **after** Material Test. No shipped library file (values depend on your tube, optics, and exhaust).

Suggested names in **Material Manager** (GUI) or console `material save <name>`:

| Preset name | Use | Starting point (tune!) |
|-------------|-----|-------------------------|
| **DLC32 — 3mm plywood cut** | Cut through | Speed/power from best **cut** cell on test card |
| **DLC32 — MDF engrave** | Light engrave | Lower power, higher speed from **engrave** cell |
| **DLC32 — Cardboard test** | Low-risk test | Very low power, fast — for alignment checks |

Steps:

1. **Edit → Material Manager**
2. Add material + thickness + laser type **CO2**
3. Add operations (cut/engrave) with your tested power/speed/pass count
4. **Save** the library section

Apply to jobs: select operations → load material from manager (status bar / tree).

---

## 4. GRBL Controller macros

If you used the **DLC32 400×285** device profile, **right-click** macros to edit; defaults:

| Button | Sends |
|--------|--------|
| Clear alarm | `$X` |
| Work zero | `G92 X0 Y0` |
| Status | `?` |
| Read settings | `$$` |
| Home Y / Home X | **`$HY`** then **`$HX`** (do **not** use MeerK40t **`$H`** / touch **Hard Home** — Y overtravels) |

**MeerK40t → Configuration → GRBL-DLC32-400:** **Has endstops** on, **TCP** `192.168.10.90:8080`, **connect delay** 500 ms. Board EEPROM: see **[19-dlc32-eeprom-settings.md](19-dlc32-eeprom-settings.md)** — **`$3=0`**, **`$23=1`**, **`$5=0`**, **`$27=5`**, **`$130=400`**, **`$131=285`**.

Do **not** use navigation **physical home** (`$H`) until MKS touch homing is fixed — use **Home Y** then **Home X** macros.

---

## 5. Safety (meerkat local)

- **Limit laser movement to bed size** — on at startup; warning if you disable.
- Board: **`$130=400`**, **`$131=285`**, **`$32=1`** — full EEPROM: [19-dlc32-eeprom-settings.md](19-dlc32-eeprom-settings.md)
- Homing (touch / web): **`$HY`** then **`$HX`** — not **`$H`** alone; **`$3=0`**, **`$23=1`**, **`$5=0`**, **`$27=5`**
- **`$22=1`**, **`$21=1`**, **`$20=1`** when limits and travel are verified

### Y jog shows **ALARM:2 — Soft limit**

GRBL blocks the move because MeerK40t sent **+Y** while the board only allows **Y ≤ 0** (into the bed is **negative**).

1. **Configuration → Device → GRBL-DLC32-400:** turn **Flip Y** **on**, **Home corner** = **top-left**, bed **400 × 285 mm**.
2. **Restart MeerK40t** (close fully, reopen) so the transform reloads.
3. **Home** (`$HY` then `$HX`), then **Clear alarm** (`$X` macro).
4. Jog **down** again — should send **Y−** (into bed), not **Y+**.

If **Flip Y** was off, the down arrow tried to move **past the top** of travel → soft limit alarm. That is expected, not a broken axis.

### **ALARM:1 — Hard limit** (switch hit / overrun)

A **real limit switch** tripped (or GRBL still thinks it did). The head may have moved **past** the end of travel — often when jogging fast toward the **far end** of Y.

| Alarm | Meaning |
|-------|---------|
| **ALARM:2** | Soft limit — move blocked in software (wrong direction or past `$130`/`$131`) |
| **ALARM:1** | **Hard limit** — limit input active with **`$21=1`** |

**Recovery (order):**

1. **Release** the switch if the head is still pressing it (jog off carefully, or power off and turn leadscrews by hand a few mm).
2. Console or macro: **`$X`** (clear alarm).
3. **`$HY`** then **`$HX`** (do **not** use **`$H`** alone on this machine).
4. Check **`?`** — **`Pn:`** should be **empty** at rest (no **P**, **X**, **Y**). If **Y** or **P** stays on, fix probe jumper / limit wiring before homing again.

**Find Y travel safely:**

1. **Home** first (**`$22=1`**, **`$23=1`**, **`$5=0`** on Andre’s board — see `16-mks-dlc32-board.md`).
2. After home, **`MPos` should be `0,0,0`** (top-left).
3. Jog **down** in **50 mm** steps; watch **`MPos Y`** go **more negative** (e.g. **−50**, **−100** … toward **−285**).
4. **Stop ~10 mm before** the mechanical end — do not ram the limit. Bottom of bed ≈ **`Y = −285`**, not **+285**.
5. Keep **`$20=1`** (soft limits). If you still overshoot, lower **`$131`** slightly (e.g. **275**) after measuring real travel.

**MeerK40t:** use **50 mm** jogs, not “move to 300” in one shot, until position and limits are trusted. **Fence (confined)** should stay **on**.

**Andre machine:** X and Y limits are **only at top-left** (off the bed). Lower-right has **no** switches — see diagram in [16-mks-dlc32-board.md](16-mks-dlc32-board.md). Alarm there = false **Pn:** or soft travel too long, not the home switches.

### Job runs (head moves) but **laser does not fire**

Touch-panel **weak/strong beam** uses **`M3 S…`** (constant power). MeerK40t defaults to **`M4`** when **Use M3** is off. With **`$32=1` (laser mode)**, **M4** scales PWM by *current speed ÷ programmed speed* — on fast jobs or high **F** values the effective power can drop below what your tube needs to strike, even though the touch panel test works.

| Check | Action |
|-------|--------|
| **Use M3** | **Configuration → Device → GRBL-DLC32-400 → Use M3 = On** (Meerkat default for this profile). Restart MeerK40t. Jobs should start with **`M3`**, not **`M4`**. |
| **Power too low** | Cut/engrave ops need enough **S** for your PSU (often **≥500** on a **$30=1000** board = 50%+). Parameter-Test cells at **S180** (18%) may not fire on CO2. |
| **Speed vs `$110`/`$111`** | If **F** in the GRBL log is far above **`$110`**/**`$111`**, M4 power stays scaled down. Lower op speed (e.g. **5 mm/s** cut) for tests. |
| **Adjust sliders** | **Laser** tab → **Adjust** → power/speed sliders at **center (0% override)**, not minimum. |
| **Chiller / WP** | Water flow must satisfy PSU **WP** during jobs (same as touch test). |
| **Only border moves** | Inner shapes not assigned to a Cut op → head travels with **S0** — see **§9**. |

**Quick verify:** Connect → **GRBL Controller** → run a tiny job or console:

```text
gcode M3 S500
gcode G1 X20 Y-20 F600
gcode M5
```

You should see the beam during the **G1** line. If that works but a full job does not, check operation **power**, **enabled**, and **Use M3**.

---

## 6. Deferred (by design)

| Feature | Status |
|---------|--------|
| Camera overlay | Skip until you need engrave-on-objects alignment |
| LightBurn `.lbrn` | Not integrated |
| Print & Cut | Not integrated |

---

## 7. ESP32-WEB vs MeerK40t

| Task | Tool |
|------|------|
| Edit **`$`** on board | `http://192.168.10.90/` (port **80**) |
| Jobs, design, simulation | MeerK40t |
| Quick jog / macros | Either; one GRBL client at a time on GRBL TCP port **8080** |

### 7.1 ESP3D SD upload (MeerK40t → SD card → run on board)

**Two ports on DLC32:** HTTP **80** (web + SD upload) and GRBL TCP **8080** (live jobs). ESP3D upload uses **port 80 only** — it does not need GRBL Controller connected.

**Enable once:**

1. **Configuration → Device → GRBL-DLC32-400 → ESP3D Upload**
2. **Enable ESP3D Upload** = On  
3. **Host** = `192.168.10.90`, **Port** = `80`, **Path** = `/`  
4. **Test Connection** → should show SD used/free space  

**Upload from MeerK40t:**

- Console: `esp3d_upload_run` (upload only) or `esp3d_upload_run -e` (upload + run)  
- Or export G-code, then upload via web `http://192.168.10.90/upload`  

Use **LF line endings** (`Configuration → Line Ending → LF` or export `*_lf.gcode`). **Home first** (`$HY` then `$HX`) before SD jobs — exported files do not homing at start.

**Manage / run files in GUI:**

1. **Laser → ESP3D Files** pane (or Window menu)  
2. **Refresh** — use the **dropdown** to pick a file (label shows **Selected: …**)  
3. **Execute** → confirm dialog → sends `[ESP220]/filename` to the board  

**Laser on SD jobs:** Files already on the card keep whatever G-code was uploaded. Old exports often use **CR-only line endings** — MKS firmware splits on `\n` only, so **`file6571.gc`-style files can “start” with no motion**. Re-upload via **`esp3d_upload_run -e`** (adds **LF** + **M3** automatically). **Home** (`$HY` / `$HX`) before **Execute**.

**If Execute says success but nothing moves:** delete old SD files (**Clear All** in ESP3D Files pane), plan your job in MeerK40t, then console **`esp3d_upload_run -e`**. Pick the **new** filename in the dropdown — do not re-run old `file*.gc` uploads.

**Console equivalents:**

```text
esp3d_list
esp3d_run_file file6571.gc
esp3d_delete file6571.gc
```

**If the list shows “Found N file(s)” but no names:** restart MeerK40t after updating (dark-theme list fix in `esp3dfilemgr.py`). You can still run by name: `esp3d_run_file test1_lf.gcode`.

**While an SD job runs:** do not connect MeerK40t GRBL TCP **8080** at the same time — one GRBL client only.

---

## 8. Reliable Wi‑Fi after power-on (avoid “router online, PC dead”)

Two separate issues showed up in practice:

| Symptom | Cause | Fix (once) |
|---------|--------|------------|
| Router lists **mks_grbl**, PC cannot ping/open web until phone/PC hits the board | ESP32 Wi‑Fi stack idle until first LAN traffic | **Wake script** (below) or open `http://192.168.10.90/` before **Connect** |
| Web UI works, MeerK40t **TCP fails** | Wrong TCP port (often **23** vs **8080**) | Set Interface port to **8080**; driver also auto-probes **8080** then **23** |

### 8.1 Check GRBL TCP port (board)

After wake, open:

`http://192.168.10.90/command?commandText=%5BESP420%5D`

On **MKS DLC32 V2.2.6** firmware Andre uses, look for:

- **Web port: 80**
- **Data port: 8080** ← MeerK40t must use this (not 23 unless you change firmware/NVS)

Port **23** may be **closed** even when the web UI works — that is normal on this firmware build.

Optional (only if you insist on port 23): run ESP links one at a time, wait for **`ok`**, restart — but **8080 is the supported path** for MeerK40t on this board.

### 8.2 Router

- **DHCP reservation**: MAC **F4-2D-C9-B2-80-70** → **192.168.10.90** so the IP never drifts.
- Board and PC on the **same SSID** (not guest-only).
- Disable **AP / client isolation** on that SSID if LAN devices still cannot see each other.

### 8.3 MeerK40t (PC side)

| Setting | Tab | Suggested |
|---------|-----|-----------|
| **Post Connection Delay** | Protocol → Validation | **500** ms if connect is flaky right after boot |
| **Reset on connect** | Protocol → Validation | On (you already have this) |
| **Interface** | Interface | **Networked**, `192.168.10.90`, port **8080** |
| USB | — | Unplug when using Wi‑Fi (one GRBL client) |

### 8.4 Auto-wake (Meerkat — no phone needed)

**On Connect in MeerK40t:** the GRBL TCP driver HTTP-wakes the board, then connects on the configured port or auto-finds **8080** / **23** (`tcp_connection.py` → `wake_lan_host`, `resolve_grbl_tcp_port`).

**When starting the app:** `run-meerk40t-dev.bat` also runs `scripts/wake-mks-dlc32.ps1` (retries ping + HTTP).

Restart MeerK40t after pulling this change so the new connect logic loads.

Manual wake:

```powershell
& "C:\Users\User\Ai Projects\meerkat\scripts\wake-mks-dlc32.ps1"
```

Edit the `$Ip` parameter in the script if the board IP changes.

### 8.5 Daily habit (if wake script is not enough)

1. Power board, wait for MKS screen / Wi‑Fi OK.
2. Start MeerK40t via **`run-meerk40t-dev.bat`** (wake runs automatically).
3. **Connect** in MeerK40t.

If connect still fails: open `http://192.168.10.90/` in the browser once, then **Connect** again.

### 8.6 Wi‑Fi jobs stop mid-cut; USB keeps going

If a job **stops on Wi‑Fi** but **continues when you plug in USB**, the GRBL **TCP link** is likely dropping (buffer stall, sleep, or a second client), not MeerK40t cancelling the design.

| Do | Why |
|----|-----|
| **USB for long engraves** until Wi‑Fi is proven stable | Serial is more reliable than LAN for sustained G-code |
| **Close ESP32-WEB** while MeerK40t is connected | Only one GRBL client on port **8080** |
| Watch **Job progress** on the **Laser** tab | Bar freezes near the last % if the link died |
| Fix **24 V / driver heat** if the **touch panel reboots** | Power loss looks like a “stopped” job too |

### 8.7 Job progress in Laser-Control

On the **Laser** tab (under Power/Speed):

- **Gauge** — 0–100% from the running **LaserJob** (steps done / total).
- **Detail line** — step count, rough time left, optional driver buffer `sent/total`, queue position.

Same data as the status-bar burn info, but always visible while you use **Start / Pause / Stop**. Progress is **spooler steps**, not “% of the drawing on screen.”

---

## 9. Only the outside border cuts (inner detail missing)

This is almost always **MeerK40t assignment**, not the DLC32 ignoring G-code. The laser only runs shapes that are **children of an enabled operation** in the **Operations** tree.

### Quick checks (2 minutes)

1. **Operations** tree → expand your **Cut** operation. Do you see **every** inner line/shape listed under it? If only the outer rectangle is there, the inner art was never queued.
2. **Elements** tree → click an inner shape. In **Properties**, note **Stroke** and **Fill** colours. The **Cut** op only picks up colours you enabled on that op (by default **stroke only**).
3. **Simulate** (or **Laser → Start** preview path). If inner paths do **not** show as red travel/cut lines, they are not in the plan.
4. Yellow **Unassigned** / **Non-burnt** bar above the tree → use **Assign** or **Assign (+new)** before **Queue to Spooler** / **Start**.

When you **Queue to Spooler** or **Arm → Start**, Meerkat now warns if any shapes are still unassigned (you can cancel and fix first).

### Most common causes

| Symptom | Cause | Fix |
|---------|--------|-----|
| Outer frame cuts; letters/shapes inside do not | Inner art is **fill-only** (no stroke); Cut classifies **stroke** by default | Cut op → **Properties** → enable **Fill** (same colour as fill), or give inner shapes a **stroke** matching the Cut colour → **Re-Classify** |
| Inner shapes use a **different colour** than the Cut op | Colour-based classification | Match stroke/fill to the Cut op colour, add a second Cut op, or **Re-Classify** with fuzzy colour on |
| Shapes sit only under **Elements**, not under **Cut** | Never classified after import | **Assign** on the warning bar, or drag selection onto the Cut op |
| You used **Outline** / **Trace hull** | Traces the **convex hull** / outer boundary only — not the full job | Use **Arm → Start** or **Queue to Spooler** for the real job, not Outline |
| **Hold** on with an old plan | Re-spools a previous plan without inner shapes | Turn **Hold** off, queue again after fixing assignments |
| Cut op **output** disabled (grey) | Op skipped in planner | Enable output on the Cut op (warning bar **Enable** for non-burnt) |

### SVG / LightBurn-style files

- **Text** and logos are often **filled paths with no stroke** → enable **Fill** on Cut or add a hairline stroke in your design app.
- One **compound path** with a hole: both contours should appear as subpaths; if the file only stroked the outer contour, re-export with inner paths as separate strokes.

### Parameter Test grid

Each cell is its own small rectangle with its own Cut op entry — if **one** square cuts but neighbours do not, check power/speed on those ops, not assignment. If **only the outer frame** of the whole grid cuts, you may have enabled **Create boundary shape** plus a single master op — expand operations and confirm every cell has a reference.

### Still wrong?

Console after planning: look for a very short job vs many `G1` segments. Compare step count on the **Laser** tab progress line to what **Simulate** shows. If Simulate shows inner paths but the machine does not, suspect Wi‑Fi drop or alarm mid-job ([§8.6](#86-wi-fi-jobs-stop-mid-cut-usb-keeps-going)); if Simulate omits them, fix the Operations tree first.
