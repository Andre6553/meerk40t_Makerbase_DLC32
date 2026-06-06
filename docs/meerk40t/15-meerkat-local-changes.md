# Meerkat workspace — local changes to MeerK40t

This note records **fork-style edits** made in the Meerkat workspace clone (`meerk40t/`), not upstream MeerK40t releases. Update this file whenever you add or change behavior here.

## 2026-06 — Scene right-click: Move laser head here

**Files:** `meerk40t/meerk40t/gui/wxmscene.py`, `meerk40t/meerk40t/gui/scenewidgets/elementswidget.py`

**Behavior:** Right-click on the main scene grid (empty area, no tool active) → **Move laser head here** sends `move_absolute` to the click position (same coordinate path as **Tools → Relocate**). Position is clamped to the device bed in scene space.

**Use:** Connect GRBL first; spooler must be idle (not mid-job). Homed machine recommended before relying on coordinates.

## 2026-06 — CO2 jobs: Use M3 (laser fires on touch panel but not in jobs)

**Files:** `MeerK40t.cfg`, `meerk40t/meerk40t/grbl/plugin.py`, `docs/meerk40t/17-meerkat-dlc32-workflow.md`

**Symptom:** Head moves during a MeerK40t job but the tube does not fire; touch-panel laser test still works.

**Cause:** Touch panel sends **`M3`** (constant PWM). MeerK40t had **`use_m3 = False`** → jobs used **`M4`**, which with **`$32=1`** scales power by speed — often too weak to strike on CO2, especially at low **S** or high **F**.

**Fix:** **`use_m3 = True`** for **GRBL-DLC32-400** (config + DLC32 device profile default). Workflow doc §5 troubleshooting table added.

## 2026-06 — GRBL false “connected” / jog & settings dead (sync mode)

**Files:** `meerk40t/meerk40t/grbl/controller.py`

**Symptom:** GRBL Controller shows green **Connected** (USB or Wi‑Fi) but the log stays empty, **Status** / **Read settings** / jog do nothing.

**Cause:** In **sync** mode, realtime commands (`?`, `!`, `~`, soft reset) were queued in the **forward buffer** and waited forever for `ok` — GRBL answers those with status reports, not `ok`. Boot validation sends `?` at the end; one stuck `?` blocked all later G-code. With **`require_validator = True`** and **`reset_on_connect = False`**, USB attach often never sends a welcome string, so validation never started.

**Fix:** `_expects_ok()` / `_send_realtime()` — status and pause/resume bytes bypass the forward buffer. `_connect_validation_fallback()` starts the `$` boot sequence if no welcome arrives within ~0.5 s.

**Use:** Restart MeerK40t → **Device-Control → GRBL Controller → Connect** → **Status** should show `<--` / `-->` traffic; jog and **Read settings** should work. Console **`grbl_validate`** still forces ready if needed.

## 2026-06 — ESP3D SD jobs: Execute “started” but machine idle

**Files:** `meerk40t/meerk40t/grbl/esp3d_upload.py`, `meerk40t/meerk40t/grbl/gui/esp3dfilemgr.py`, `meerk40t/meerk40t/grbl/plugin.py`, `docs/meerk40t/17-meerkat-dlc32-workflow.md`

**Symptom:** ESP3D Files **Execute** reports success; head/laser do nothing even after homing.

**Cause:** MKS firmware `readFileLine()` splits on `\n` only. Old MeerK40t exports used **CR** line endings → SD file unreadable (silent no-op). Old files also had **M4** instead of **M3** for CO2.

**Fix:** `prepare_sd_gcode_file()` on upload (LF + M3). `execute_file()` uses `PAGEID=0`, parses Alarm/Busy, polls GRBL `?` after ESP220. ESP3D Files pane uses dropdown + clear failure messages. Re-upload via **`esp3d_upload_run -e`**.


**Files:** `docs/meerk40t/19-dlc32-eeprom-settings.md`, `meerk40t/meerk40t/grbl/plugin.py`, `docs/meerk40t/17-meerkat-dlc32-workflow.md`, `docs/meerk40t/16-mks-dlc32-board.md`

**Saved (Andre, homing verified):** **`$3=0`** (jog + touch screen), **`$23=1`** (homing — Y correct like `$23=0`, X homing inverted), **`$5=0`**, **`$27=5`**, **`$HY`** then **`$HX`**. Full snapshot: **`19-dlc32-eeprom-settings.md`**.

**Bed:** **`$130=405`**, **`$131=285`** — full `$$` snapshot in **`19-dlc32-eeprom-settings.md`** and Cursor rule **`.cursor/rules/dlc32-eeprom-settings.mdc`** (always apply).

## 2026-05 — Scene startup crash (0×0 window / null background bitmap)

**Files:** `meerk40t/meerk40t/gui/scene/scene.py`

**Problem:** MeerK40t could crash on start with `MemoryDC.SelectObject(): argument 1 has unexpected type 'NoneType'` in `_update_buffer_ui_thread` when `ClientSize` was **0×0** before the window laid out.

**Fix:** `LayerCache.ensure_size` allocates at least **1×1** bitmaps when size is zero and does not skip allocation when `_size` is already `(0,0)` but bitmaps were never created. `_update_buffer_ui_thread` returns early for zero client size and before using a missing background bitmap.

## 2026-05 — Queue warning when shapes are unassigned

**Files:** `meerk40t/meerk40t/gui/laserpanel.py`, `docs/meerk40t/17-meerkat-dlc32-workflow.md` (§9)

**Problem:** Jobs could run with only the **outer border** cutting because inner geometry was never assigned to a Cut op (common with **fill-only** SVG art).

**Fix:** **`queue_cutplan_to_spooler()`** warns if **`have_unassigned_elements()`** before spooling (cancel or queue anyway). Workflow doc §9 lists classification fixes (stroke vs fill, Re-Classify, Outline vs full job).

## 2026-05 — Parameter-Test → spooler queue + Hold fix

**Files:** `meerk40t/meerk40t/gui/materialtest.py`, `meerk40t/meerk40t/gui/laserpanel.py`, `docs/meerk40t/17-meerkat-dlc32-workflow.md`

**Problem:** **Parameter-Test** only runs **Create Pattern** (scene ops); **Arm → Start** often left the **Job Spooler** empty — especially with **Hold** on (re-spool old plan without blob), **threaded** planning still running, or no burnable ops after a failed create.

**Fix:** Shared **`queue_cutplan_to_spooler()`** in `laserpanel.py` (checks device connected, burnable ops; **Hold** only re-spools when the held plan already has a **blob** stage). **Parameter-Test** adds **Queue to Spooler** (always rebuilds from scene). Clearer workflow doc steps.

## 2026-06 — Laser-Control job progress bar fix

**Files:** `meerk40t/meerk40t/gui/laserpanel.py`

**Problem:** **Job progress** stayed at **“No job running”** (or froze at 0%) during burns. The panel listened for `spooler;update`, but that signal is only relayed inside the status-bar widget — it is **never** emitted on the kernel signal bus. During a job, only `spooler;queue` (at enqueue) and `spooler;completed` fired, so the gauge rarely refreshed. Progress also used top-level `item_index` / `len(items)`; typical jobs have one `CutCode` item, so the bar stayed at **0%** even when updates did run.

**Fix:** Listen to **`driver;position`** and **`emulator;position`** (same as **Job Spooler**). Compute **%** from **`steps_done` / `steps_total`** when available, with fallback to item index. Throttled ~1 s. Idle: “No job running”.

## 2026-05 — Laser-Control job progress bar

**Files:** `meerk40t/meerk40t/gui/laserpanel.py`, `docs/meerk40t/17-meerkat-dlc32-workflow.md`

**Behavior:** On the **Laser** tab of **Laser-Control**, a **Job progress** gauge shows **0–100%** while a `LaserJob` is running (spooler steps). A detail line shows step counts, rough time remaining, optional GRBL send-buffer counts (`current/total` from the driver), and queue position when multiple jobs are queued. Updates on `spooler;queue`, `spooler;completed`, and position signals (throttled ~1 s). Idle: “No job running”.

**Note:** Progress reflects **planner/spooler steps**, not “% of drawn geometry on screen.” If Wi‑Fi drops, the bar may freeze and the job stops — use USB for long cuts until the link is stable (see workflow doc §8).

## 2026-06 — Sequential homing ($HY / $HX) for DLC32

**Files:** `meerk40t/meerk40t/grbl/driver.py`, `device.py`, `gui/navigationpanels.py`, `grbl/plugin.py`, `MeerK40t.cfg`

**Problem:** MeerK40t **Home** sent **`$H`** or **`G28`**; homing stopped **~50 mm** before **X− / Y+** switches with **ALARM:1**.

**Fix:** Device setting **Sequential homing** — **`physical_home`** sends **`$HY`** then **`$HX`**. **Home** toolbar button calls **`physical_home`** when **Has endstops** is on. DLC32 profile defaults: endstops on, sequential on; macros **Home Y** / **Home X**.

## 2026-06 — GRBL MPos sync + ALARM:1 hard limit notes

**Files:** `meerk40t/meerk40t/grbl/controller.py`, `docs/meerk40t/17-meerkat-dlc32-workflow.md`

**MPos sync:** After connect, `declare_position()` now runs on every status **`MPos:`** update so MeerK40t confined jogs match the board (avoids commanding extra travel when the head was moved on the touch panel).

**ALARM:1:** Documented recovery and safe Y travel (home → jog down in steps toward **−300**, stop before ramming the switch). See workflow doc §5.

## 2026-06 — GRBL ALARM:2 on Y jog (Flip Y must be on)

**Files:** `MeerK40t.cfg`, `meerk40t/meerk40t/grbl/controller.py`, `docs/meerk40t/17-meerkat-dlc32-workflow.md`

**Symptom:** **ALARM:2 Soft limit** when jogging Y in MeerK40t; X OK.

**Cause:** Board **MPos Y** is **0 at top**, **negative into bed**. With **Flip Y off**, MeerK40t’s down jog sends **G91 Y+** → past soft limit. Saved config had **`flip_y = False`**.

**Fix:** **`flip_y = True`**, **`home_corner = top-left`**. One-time console warning if MPos Y &lt; 0 and Flip Y is off.

## 2026-06 — GRBL Y jog in MeerK40t (confined + home corner)

**Files:** `meerk40t/meerk40t/grbl/driver.py`, `MeerK40t.cfg` (`[grbl1]`), `meerk40t/meerk40t/grbl/plugin.py`

**Problem:** X jog worked; **Y jog did nothing** in Navigation (down arrow) while the touch panel moved Y fine. Board uses **MPos Y 0 at top** and **negative Y into the bed** (e.g. **−300**).

**Cause:** `move_rel(confined=True)` compared **native** `native_y` with **UI** jog deltas (`0…300`). That mixed coordinate systems and often zeroed `dy` (e.g. at home, or when `native_y` was already negative). **`home_corner=auto`** also left the bed origin wrong for top-left homing with **`flip_y=True`**.

**Fix:** Confined clamping now uses **`device.current`** (bed/UI coords), same as the Navigation panel. Saved device: **`home_corner=top-left`**, **`bedwidth=405mm`**. DLC32 profile defaults: **405×300**, **`swap_xy=False`**, **`flip_y=True`**, **`home_corner=top-left`**.

**User:** Restart MeerK40t after pulling this change. In **Configuration → Device**, confirm **Home corner = top-left**, **Flip Y = on**, bed **405×300 mm**. Jog **down** should move into the bed; **up** toward home.

## 2026-06 — DLC32 X steps/mm calibrated (`$100=158`)

**Board EEPROM (Andre):** **`$100=158`** so **`G0 X100`** moves **100 mm** real (was **80** — display reached **400** while X only traveled ~half). **`$101=160`** unchanged (Y full travel to **−300**). Homing: **`$HY`** then **`$HX`**, **`$23=1`**, **`$5=0`**, **`$27=3`**, probe/Z/unused limits **GND–S** jumpers. Doc: `16-mks-dlc32-board.md`, `17-meerkat-dlc32-workflow.md`.

## 2026-06 — DLC32 GRBL TCP port 8080 (not 23)

**Files:** `meerk40t/meerk40t/grbl/tcp_connection.py`, `meerk40t/meerk40t/grbl/plugin.py`, `scripts/wake-mks-dlc32.ps1`, `docs/meerk40t/17-meerkat-dlc32-workflow.md` (§8)

**Cause:** MKS DLC32 V2.2.6 reports **Data port: 8080** in `[ESP420]`; port **23** is refused even when `http://192.168.10.90/` works.

**Behavior:** On connect, after HTTP wake, `resolve_grbl_tcp_port()` tries configured port, then **8080**, then **23**. Device profile and saved config use **8080**. Wake script checks TCP **8080** after HTTP.

## 2026 — DLC32 Wi‑Fi wake (script + TCP connect)

**Files:** `meerk40t/meerk40t/grbl/tcp_connection.py`, `scripts/wake-mks-dlc32.ps1`, `run-meerk40t-dev.bat`, `docs/meerk40t/17-meerkat-dlc32-workflow.md` (§8)

**Behavior:** Before GRBL TCP connect, MeerK40t HTTP-wakes the board (same as opening the phone browser), retries TCP up to 4×. Launcher script retries wake 8×. Doc covers DHCP reservation, Post Connection Delay 500 ms.

**Fix (same file):** Removed 8 s read timeout on the live TCP socket — it had caused connect-then-disconnect ~8 s later during `$$` validation over Wi-Fi. Connect still uses 8 s timeout; reads are blocking again.

## 2026 — Backup-before-edit rule + DLC32 400×300 device profile

**Rules:** `.cursor/rules/meerkat-backup-before-edit.mdc` — agent must rotate `.bak.1`–`.bak.3` before any edit under `meerk40t/`, `docs/meerk40t/`, or `.cursor/rules/`.

**Files:** `meerk40t/meerk40t/grbl/plugin.py`, `meerk40t/meerk40t/grbl/device.py`, `docs/meerk40t/17-meerkat-dlc32-workflow.md`

**Behavior:**

- New device type **K40 CO2 — MKS DLC32 (400×300 mm)** (`dev_info/grbl-dlc32-k40-400`): bed 400×300, Swap XY, TCP `192.168.10.90:8080`, reset on connect, five GRBL macros.
- `dev_info` choices can set `macro_0` … `macro_title_4`; persisted when the device is created.
- Workflow doc covers Material Test, Material Manager presets (manual), macros, safety — camera/LBRN deferred.

## 2026 — Bed movement limit on by default + disable warning

**Files:** `meerk40t/meerk40t/gui/navigationpanels.py`, `meerk40t/meerk40t/gui/plugin.py`, `meerk40t/meerk40t/core/spoolers.py`

**Behavior:**

- **Limit laser movement to bed size** (confined) is turned **on** when MeerK40t starts and when the Jog panel opens.
- Clicking the fence button to **turn it off** shows a **warning** (Yes/No, default No) about GRBL max travel, alarms, and driver stress before allowing unconfined jogs.
- Console/spooler `move_relative` uses confined **True** by default if the setting is missing.

## 2026 — GRBL confined jog crash (bed size strings)

**Files:** `meerk40t/meerk40t/grbl/driver.py`

**Problem:** Jogging to the bed edge (e.g. **Y to max** with **Confined** on) could crash MeerK40t with `TypeError: unsupported operand type(s) for -: 'str' and 'float'` because `view.width` / `view.height` are stored as length strings (e.g. `"400mm"`) but `move_rel(confined=True)` compared and subtracted them as raw values.

**Fix:** Convert `dx`, `dy`, and bed limits with `float(Length(...))` before confined clamping.

**Backups:** `driver.py.bak.1` … `.bak.3` beside the file.

## 2026 — Simulation preview cache

**Files:** `meerk40t/meerk40t/gui/simulation.py`

**Behavior:** While the simulation panel rebuilds raster/plot preview caches, the **Send to Laser** button label becomes **Calculating**. A **Stop calculating** button appears below it so you can abort that phase without closing the app.

**Mechanism:** Cooperative cancel (`wx.YieldIfNeeded()` between cuts, cancel flag). UI cleanup runs in a `finally` block so the spool button is restored.

**Limit:** Cancellation applies **between** cuts. A single very large raster can still block inside one `list(plot…)` until that call finishes.

**Backups:** Rotating snapshots `simulation.py.bak.1` … `.bak.3` beside the file (see workspace Cursor rule §4).

## 2026 — Tips at startup preference

**Files:** `meerk40t/meerk40t/gui/tips.py`

**Behavior:** Toggling **Show tips at startup** now calls `context.write_persistent("show_tips", state)` so the choice is saved immediately instead of only on shutdown.

## 2026 — Ribbon toolbar: delayed description tooltip

**Files:** `meerk40t/meerk40t/gui/ribbon.py`, `meerk40t/meerk40t/gui/plugin.py`

**Behavior:** The ribbon bar uses its own hover timer (default **2000 ms**). After you pause on a toolbar button that long, the tooltip shows the **short tip** and, when defined, the **extended help** text in one popup (two paragraphs separated by a blank line).

**Preference:** **Gui → Tooltips → Ribbon: hover before description** (`ribbon_tooltip_delay_ms`). **Gui → Tooltips → Long ribbon hover descriptions** (`ribbon_verbose_hover_help`) and **Panes → Help → Long hover descriptions on ribbon toolbars** (same setting). The global **ToolTip delay** still applies to other controls only (via `wx.ToolTip.SetDelay`).

**Scope:** Only the **custom ribbon strips** at the top (`wxmribbon.py`: primary, tools, edit/modify). Other panes (scene, tree, etc.) use normal wx tooltips, not this delayed ribbon job.

**Tree / scene context menus:** The same **`ribbon_verbose_hover_help`** flag controls **`create_menu_for_node`** in `wxutils.py`: when it is on, each menu item’s status-bar help uses formatted `help=` text from `element_treeops.py`, and if that is empty, the first paragraph of the operation’s docstring (when present). **Look at the status bar** while moving through a right-click menu (not a floating tooltip). When the flag is off, only explicit `help=` strings are used (no docstring fallback).

## 2026-06 — Laser-Control override: 5% steps, typed Set, power direction fix

**Files:** `meerk40t/meerk40t/gui/laserpanel.py`, `meerk40t/meerk40t/grbl/driver.py`

**Problem:** Override sliders moved in **10%** steps only. No way to type a value. **Power slider felt reversed** on GRBL/DLC32: moving right (+70%) reduced burn because `0x9A`/`0x9B` spindle commands were swapped vs GRBL 1.1 (increase/decrease).

**Fix:** Sliders use **5%** steps (center = 0%, range about −100% to +100%). Small **text + Set** beside Power and Speed for typed percent (e.g. `70`, `-30`). GRBL driver resets to 100% then steps in **5%** with correct **0x9A** increase / **0x9B** decrease.

**Use:** Enable **Override**, adjust while engraving; **right = more power**, **left = less**.

## 2026-06 — Material Manager delete-by-category crash fix

**Files:** `meerk40t/meerk40t/gui/materialmanager.py`

**Problem:** Right-click **Delete category** (e.g. under **&lt;All Lasertypes&gt; → New material**) crashed with `AttributeError: 'int' object has no attribute 'replace'` because `laser` is stored as an integer index, not a string.

**Fix:** `_entry_category_label()` maps laser indices to the same labels as the library tree; delete matching uses that helper. Also fixed secondary-key comparison in the delete loop (`sec_key == secondary`).

## 2026-06 — Tree panel material preset dropdown

**Files:** `meerk40t/meerk40t/gui/wxmtree.py`

**Behavior:** On the **Tree → Details** tab, a **Material:** dropdown lists all **Material Manager** library entries (e.g. `Acrylic — 3mm — …`). Choosing one runs `material load` — the **Operations** branch is replaced with that preset’s cut/engrave/raster speeds and powers (same as right-click **Operations → Load → …**). Optionally updates the status-bar operation buttons when **Update Statusbar on load** is checked (right-click **Operations** menu).

**Use:** Create presets in **Edit → Material Manager**, restart MeerK40t if the list was open during edits, then pick from the dropdown.

## 2026-06 — Keyboard Delete matches ribbon Delete

**Files:** `meerk40t/meerk40t/gui/scene/scenepanel.py`, `meerk40t/meerk40t/gui/wxmtree.py`, `meerk40t/meerk40t/gui/wxutils.py`, `meerk40t/meerk40t/core/bindalias.py`

**Problem:** Ribbon **Delete** worked (`tree selected delete`) but **Delete** / numpad **Del** on the canvas often did nothing (key-up vs key-down on Windows; numpad not in the default keymap).

**Fix:** Default keymap adds **`numpad_delete` → `tree selected delete`**. Scene panel runs the same command on **key-up** when the keymap did not already fire on key-down (mirrors the tree widget). Tree **key-up** handles numpad Delete too.

**Use:** Select shape(s) on the scene, press **Delete** or numpad **Del** — same as the ribbon button. While a draw/edit tool is active (`tool_active`), tools keep priority. Console **Window → Keymap** can still remap `delete` / `numpad_delete`.

## 2026-06 — Tree double-click on operations opens Parameter-Test

**Files:** `meerk40t/meerk40t/gui/wxmmain.py`, `meerk40t/meerk40t/gui/materialtest.py`

**Problem:** Double-clicking a **Cut / Engrave / Raster / Image / Dots** operation in the **Tree** opened the standalone **Properties** window (or element PathNode for mis-clicks) instead of **Parameter-Test** with the operation’s speed/power tabs.

**Fix:** `open_property_window_for_node()` routes laser operation types to **`window/Templatetool`** (title **Parameter-Test**), syncs the **Generator** operation combo via `select_operation_for_node()`, and embeds the real operation node in the notebook **Properties** tab (`focus_properties=True`). **Elements** (paths, text, images) still open **Properties** as before.

**Use:** Restart MeerK40t after pulling. Double-click **Cut** or **Engrave** under **Operations** in the tree — expect **Parameter-Test**, **Properties** tab selected. Double-click geometry under **Elements** — still the normal **Properties** editor.

## Workspace rules (Cursor)

**File:** `.cursor/rules/meerk40t-knowledge-base.mdc`

- **§4:** Rotate three `.bak.N` backups before substantive edits under `meerk40t/`.
- **§5:** When code behavior changes, update `docs/meerk40t/README.md` and the relevant topic note (such as this file) in the same batch; update the workspace root `README.md` if one exists and should mention the change.
