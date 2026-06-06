# MKS DLC32 Integration with MeerK40t

This document outlines the Makerbase MKS DLC32 board specifications and how to configure it for use with MeerK40t's GRBL driver.

## Overview of the MKS DLC32

The Makerbase MKS DLC32 is an advanced 32-bit offline engraving master control kit primarily designed for desktop laser engravers and small CNC machines. It acts as a major upgrade over traditional 8-bit controllers (such as the standard M2 Nano or Arduino Uno-based GRBL boards), heavily enhancing speed, memory, and connectivity options.

### Key Hardware Improvements

- **Microcontroller:** Features a 32-bit ESP32-WROOM-32U running at 240MHz.
- **Memory:** Upgraded to 8MB Flash and 520KB RAM, allowing for robust buffering of G-code instructions.
- **Speed Capabilities:** The maximum laser travel speed has been increased to **8000 mm/min** (up from 3000 mm/min on earlier 8-bit models).
- **Interface & Connectivity:**
  - **WiFi & Web UI:** Native support for wireless networking, making it accessible over standard TCP/IP.
  - **Display Screen:** Capable of directly driving a 3.5-inch (TS35) or 2.4-inch (TS24) touch color screen.
  - **Offline Engraving:** Ability to read G-code directly from an SD card.

### Hardware Revisions

Through different iterations, the MKS DLC32 has refined its hardware layout:
- Relocation of components for better reliability (e.g., driver output resistors).
- Implementation of microstepping settings via DIP switches instead of jumper caps.
- Inclusion of debugging LEDs (e.g., for WiFi) and plug-in type fuses.
- Adjusted mounting holes and high-quality PCB manufacturing (black immersion gold).

## Configuring the MKS DLC32 for MeerK40t

Because MeerK40t natively features a GRBL driver, driving the MKS DLC32 board is extremely straightforward, provided you configure it correctly.

### 1. Connecting via USB Serial
The most common connection method is a direct USB hookup. The DLC32 presents itself as a standard CH340 serial device.
1. Connect the board to your computer via USB.
2. In MeerK40t, create a new device and select the **GRBL** driver profile.
3. Under the device's configuration, set the **Port** to match the COM port assigned to the CH340 driver (e.g., `COM3` on Windows, `/dev/ttyUSB0` on Linux).
4. Ensure the **Baud Rate** is set appropriately (typically 115200 for GRBL controllers).

### Connecting the Water Flow Meter / Interlock
Your machine includes a water flow meter/sensor, which is critical for protecting the laser tube from overheating. 

1. **Locate the Sensor Wires:** Your water flow meter will have two signal wires. When water is flowing properly, the sensor acts as a closed switch (connecting the two wires together).
2. **Wire to the PSU:** 
   - Connect one of the sensor wires to the **`WP` (Water Protect)** pin on your Cloudray M60 PSU.
   - Connect the other sensor wire to the **`G` (Ground)** pin on the PSU.
3. **How it works:** When the water chiller is running and water is flowing, the sensor closes the circuit, grounding the `WP` pin. The power supply reads this ground signal and enables the high voltage. If water stops flowing, the switch opens, breaking the connection to ground, and the PSU instantly kills power to the laser tube, preventing it from cracking due to thermal shock.
The DLC32 firmware is built on top of the `Grbl_Esp32` project (using PlatformIO). Some notable architectural details include:
- **I2S Stepper Output:** The firmware uses an I2S shift register approach (`USE_I2S_OUT`) for step and direction pins. This means the standard step/dir signals are serialized over an I2S stream (BCK on GPIO 16, WS on GPIO 17, DATA on GPIO 21) rather than eating up standard GPIO pins on the ESP32.
- **Pin Mapping (V1.0 vs V2.0):** 
  - **Spindle/Laser PWM:** Moved from `GPIO_NUM_22` on V1.0 to `GPIO_NUM_32` on V2.0.
  - **Probe:** Moved from `GPIO_NUM_2` on V1.0 to `GPIO_NUM_22` on V2.0.
- **Machine Profiles:** The firmware compiles against different machine profiles depending on the hardware (e.g. `i2s_out_xyz_mks_dlc32.h` for normal Cartesian machines and `i2s_out_corexy_mks_dlc32.h` for CoreXY kinematics).

### 3. GRBL Configuration Parameters
The DLC32 firmware extends standard GRBL with customized `[ESPxxx]` tags for specific board functions (like WiFi SSID and password setup). 

When connecting MeerK40t to the board, it utilizes standard GRBL commands (`$x=y`). The critical parameters to ensure are set properly include:
- **Laser Mode (`$32=1`):** Ensure this is enabled. When set to `1`, GRBL adjusts laser power proportionally to movement speed, reducing burns on corners or accelerations.
- **Steps per mm (`$100`, `$101`, `$102`):** Depending on your specific belts and pulleys, calibrate these to match the mechanical travel resolution.
- **Maximum Feed Rates (`$110`, `$111`):** You can take advantage of the DLC32's processing power by setting these up to `8000.000` (or whatever your physical mechanics can safely handle).

### Limit switches — Andre 3040/6040 (top-left home only)

Physical layout (confirmed on machine):

```text
  [X−] [Y+]  ← only limit switches (top-left, off the bed)
        ┌─────────────────────────┐
        │      WORK BED           │
        │                         │
        │              [head]     │  ← lower-right = max travel, NO switches here
        └─────────────────────────┘
```

| Switch | Position | DLC32 header | Homing (`$23=1`) |
|--------|----------|--------------|------------------|
| **X** | Left of bed | **X−** | X homes **negative** (toward left) |
| **Y** | Top of bed | **Y+** | Y homes **positive** (toward top) |

After homing: **`MPos ≈ 0,0,0`**. Into the bed: **X+**, **Y−** (e.g. **400**, **−285**). There are **no** switches at lower-right.

**Confirmed EEPROM (Andre, 2026-06):** [19-dlc32-eeprom-settings.md](19-dlc32-eeprom-settings.md) — **`$3=0`**, **`$23=1`**, **`$130=400`**, **`$131=285`**, homing **`$HY`** then **`$HX`**.

**Jumper unused headers (GND–S)** so GRBL does not see a false limit at the far corner:

| Header | Use on Andre machine |
|--------|----------------------|
| **X−** | X home switch (wired) |
| **Y+** | Y home switch (wired) |
| **X+** | **Jumper GND–S** (no right-hand switch) |
| **Y−** | **Jumper GND–S** (no bottom switch) |
| **Z−** / **Z+** | **Jumper GND–S** (AC Z not on DLC32) |
| **Probe** | **Jumper GND–S** if no probe |

If **ALARM:1** happens at **lower-right**, the **top-left switches are not being hit** — check **`?`** → **`Pn:`** (floating **X+**, **Y−**, or **Probe** is common). Use **`$20=1`** soft limits; stop ~10 mm before the mechanical corner; **`$131`** / **`$130`** must match real travel.

### Homing from MeerK40t (stops ~50 mm before switches)

**Do not use `$H`** (homes both axes at once). On this machine that often trips **ALARM:1** while the head is still **~50 mm** from the real **X− / Y+** switches.

| Use | Avoid |
|-----|--------|
| **`$HY`** then **`$HX`** (two lines) | **`$H`**, MeerK40t old **`G28`**-only home |
| MeerK40t: **Device has endstops** + **Sequential homing** on → **Home** button runs **`$HY`** then **`$HX`** | Right-click only with endstops off |

Before homing: **`$X`**, then **`?`** → **`Pn:`** must be **empty** at rest. Use **`$23=1`** on Andre’s machine (X homing inverted; Y homing correct). **`$3=0`** for jog/touch screen — do not confuse with **`$23`**. **`$22=1`**. While testing false limits: **`$21=0`**, home, then **`$21=1`** when **`Pn:`** is clean.

### ALARM:1 only on **fast** moves

**ALARM:1** = limit **input** seen by GRBL (**`$21=1`**), not “motor current too low” directly. Untuned **Vref** can still **cause** it: weak torque → **skipped steps** / vibration → electrical **noise** on limit wires.

| Check | Action |
|-------|--------|
| **Vref** | Set **X** and **Y** (~**0.80 V** for your motors). DIP **1/16** on both A4988s. |
| **Limit noise** | **`$21=0`**, fast jog — if alarm **stops**, fix **jumpers** (X+, Y−, Probe) and route limit wires **away** from motor cables. |
| **Acceleration** | Lower **`$120`/`$121`** (e.g. **800**) if motors buzz or stall. |
| **`Pn:`** | Send **`?`** when alarm happens — note letters (**X**, **Y**, **P**). |

### Touch screen — laser “50%” turns off after a few seconds

The TS35 **Power / weak beam / strong beam** buttons (MKS firmware) send **`M3 S…`** then **`G1 F1000`** with **no X/Y move** (`MKS_draw_power.cpp` → `set_power_value()`). With **`$32=1` (laser mode)** — required for your machine — GRBL only keeps PWM **on during motion**. A move with no distance finishes immediately, so the beam stops even though the screen still looks “on”.

| Button on screen | Firmware sends | Note |
|------------------|----------------|------|
| Weak (低/弱光) | `M3 S50` + `G1 F1000` | **S50** is not “50%” unless `$30=100`; with `$30=1000` that is **5%** |
| Strong (强光) | `M3 S500` + `G1 F1000` | Same “no travel” issue |
| Off | `M5` | Laser off |

**This is normal for that UI**, not a Cloudray fault by itself. For a **steady** test beam (with chiller running and **`WP` satisfied**):

- Use **MeerK40t** → **Navigation** → **Pulse** (timed test), or jog slowly while testing power from the PC, or  
- Use the PSU **TEST** terminal only for a **brief** HV check (water flowing, eye protection, never bypass **`WP`** permanently).

If the tube fires briefly then dies even on **TEST** or with water confirmed, check **`WP` + flow sensor** (below) before blaming the DLC32.

### 24 V power — brownout / board “reboot” at engraving speed

If **ESP32-WEB** or the serial log shows **`Grbl 1.1h`** again and again, or the UI “resets” when motors run **fast**, the **24 V rail is sagging** (brownout), not a normal GRBL setting.

| Cause | What to do |
|-------|------------|
| **PSU too small** | Use **24 V, ≥10 A** (~**240 W**) for DLC32 + 2× NEMA17 at **Vref ~0.8 V**. Many small “24 V 5 A” LED supplies fail on acceleration. |
| **Vref just raised** | **0.8 V on X and Y** ≈ **~1 A per motor** → much higher peak current than factory-low Vref. |
| **Thin/long 24 V cable** | Short, thick leads to board **V+ / GND** screws; check connector heat. |
| **Same PSU as chiller/fans** | Prefer **dedicated 24 V** for the DLC32 or measure sag under load. |

**Test:** Multimeter on **24 V at the board** while jogging fast. If voltage drops below **~20–21 V**, fix power before tuning GRBL.

**Software soft test:** Lower **`$120`/`$121`** (accel, e.g. **500**) and **`$110`/`$111`** (max mm/min, e.g. **3000**) — if reboots stop, supply or current is the limit.

Signs of brownout: Wi‑Fi drop, touch UI freeze, **`ALARM`** spam, **`Grbl 1.1h ['$' for help]`** repeating right when steppers accelerate.

### 4. Wiring Peripherals (Sensors and Z-Axis)
- **Water Flow Meter:** Wire your water flow sensor directly to the PSU. One wire goes to `WP` (Water Protect) and the other to `G` (Ground). If water stops flowing, the PSU instantly cuts high voltage to the laser, completely bypassing the DLC32 for safety.
- **Z-Axis (AC Gear Motors):** If your machine uses a 220V AC gear motor for the Z-axis (e.g., Linix YN60-10 or YN60-220-10), **do not connect it to the DLC32**. It must remain wired to the physical Up/Down switch on the machine chassis. The DLC32 only supports low-voltage stepper motors.

### Supported Components Check
As an example, if you are upgrading an M2 Nano machine to the MKS DLC32, here is how typical components map over and whether they are supported by MeerK40t:
- **Cloudray / Generic Laser PSU (e.g. M60):** Board **S** → PSU **IN**, board **TTL** pin (GND) → PSU **G**, **TL→G** on PSU. Do not use the **V** pin on S-TTL-V for Cloudray. MeerK40t uses `$32=1` laser mode.
- **NEMA 17 steppers (Andre 3040/6040):** See **Motor specs and A4988 Vref** below.
- **AC Z-Axis Motors (e.g., Linix YN60-220-10):** Independent. Because these run on 220V AC wall power, they cannot connect to the DLC32. MeerK40t will not be able to auto-focus or step the Z-axis. You simply use the physical switches on the machine to focus before hitting "Start" in MeerK40t.

## Motor specs and A4988 Vref (Andre — 3040/6040)

**Drivers:** plug-in **A4988**, DIP **1/16** (all three switches **ON** per DLC32 manual A4988 table).  
**Formula (MKS, Rs = 0.1 Ω on typical red A4988):** `Vref = I × 0.8` where **I** = run current in amps (measure pot screw vs **GND**, motor unplugged, **24 V on**).

### X axis (installed)

| Item | Value |
|------|--------|
| Part number | **17HW3406N-16AD-Y** |
| Step angle | Likely **0.9°** ( **`$100=158`** matches Y-style **160** scaling) |
| Rated current | **~1.0–1.6 A** (suffix **16AD** — treat as **~1.0 A run** unless label/datasheet says otherwise) |
| Board plug | **X-Motor** |
| GRBL **`$100`** | **158** (measured — trust ruler) |
| **A4988 Vref target** | **~0.80 V** (~1.0 A run). Measure coil **Ω**: **~4 Ω** → **0.80 V**; **~13 Ω** → lower current motor → **~0.50 V** |

### Y axis (installed)

| Item | Value |
|------|--------|
| Part number | **17HW4410N-03AD-Z** |
| Step angle | **0.9°** |
| Rated current | **~1.0 A** |
| Board plug | **Y1-Motor** (Y2 empty) |
| GRBL **`$101`** | **160** |
| **A4988 Vref target** | **~0.80 V** (~1.0 A run) |

**Set Vref on both X and Y driver slots** before fast jogs. Factory pots are often **far too low** → stutter at speed → can look like limit/position faults.

### Other Y spares (not installed)

| Part number | Vref hint |
|-------------|-----------|
| **17HA801Y-22P2** | **~0.50 V** (~0.6 A) |

**Sanity check without datasheet:** measure resistance between one coil pair (motor wires, not powered): **~13 Ω** → likely **801Y (0.6 A)**; **~4 Ω** → likely **4410N (~1 A)** class.

### A4988 Vref quick table (Rs = 0.1 Ω)

| Run current | Vref |
|-------------|------|
| 0.5 A | 0.40 V |
| 0.6 A | 0.48 V |
| 0.8 A | 0.64 V |
| 1.0 A | 0.80 V |
| 1.1 A | 0.88 V |

MKS reference: [Drivers_A4988 wiki](https://github.com/makerbase-mks/MKS-GEN_L/wiki/Drivers_A4988) — `I = Vref / (8 × Rs)`.
