# Lihuiyu / K40 — first dive (priority path)

You indicated uncertainty on priorities; **this is the recommended first deep-read** because:

- Stock K40 boards use **Lihuiyu** controllers (M2/M3-Nano family).
- Your running title bar showed **`lihuiyu-device`**.

## Start here (reading order)

1. **`meerk40t/lihuiyu/plugin.py`**  
   What services, devices, and console hooks this driver registers.

2. **`meerk40t/lihuiyu/`** tree (parallel files)  
   Typical pattern: `device.py`, `driver.py`, connection helpers, EEPROM/USB specifics—**exact filenames**: list the directory in your clone (`dir` / Explorer). Use plugin imports as a map.

3. **`meerk40t/device/basedevice.py`** (via `basedevice` plugin)  
   How MeerK40t abstracts “a laser device” so the GUI can stay similar across drivers.

4. **`meerk40t/gui/laserpanel.py`**  
   What the user clicks before a job runs (arm, start, device combo).

5. **`meerk40t/core/spoolers.py`** + **`meerk40t/core/planner.py`**  
   How queued operations become driver calls.

## USB / protocol note

Lihuiyu uses vendor-specific USB patterns; **pyusb** appears in project requirements. When debugging connection issues, distinguish:

- **MeerK40t driver code** (Python under `lihuiyu/`)
- **OS / driver / cable / board** layer (outside this repo)

## Cross-links

- Plugin order: `internal_plugins.py` loads **lihuiyu** before GUI—device types exist before main window opens.
- Console / server: `main.py` mentions `lhyserver` as a substring affecting **partial** kernel mode when used with `-e`.

## Next expansions (optional future docs)

- Deeper Lihuiyu detail: [10-lihuiyu-deep.md](10-lihuiyu-deep.md)
- GRBL: [08-grbl.md](08-grbl.md)
- Ruida: [09-ruida.md](09-ruida.md)
- Galvo: [12-balormk-galvo.md](12-balormk-galvo.md)
