# GRBL EEPROM — annotated (`Firmware Settings/settings`)

**Machine:** K40 CO2, MKS DLC32 (Grbl 1.1h), Andre — Mossel Bay workspace  
**Source:** live `$$` dump in [`settings`](settings) (canonical — edit that file when EEPROM changes).  
**Board UI:** ESP32-WEB → Control → SD / File / Settings, or MeerK40t console **`$$`**.  
**Regenerate this file:** say **`/settings`** in Cursor after updating `settings`.

---

## Quick reference (Andre)

| Topic | Values |
|-------|--------|
| **Bed travel** | X **405 mm** (`$130`), Y **285 mm** (`$131`) |
| **Steps/mm** | X **157.210** (`$100`), Y **159.600** (`$101`) |
| **Max speed** | X **5500 mm/min (~91.7 mm/s)** (`$110`), Y **5000 mm/min (~83.3 mm/s)** (`$111`) |
| **Acceleration** | X **500** (`$120`), Y **400** (`$121`) mm/s² |
| **Laser mode** | **`$32=1`** — PWM scales with speed on **M4** |
| **PWM range** | **`$30=1000`** (100%), **`$31=50`** (min) |
| **Homing** | **`$22=1`**, **`$23=1`** — use **`$HY`** then **`$HX`** (not **`$H`**) |
| **Jog direction** | **`$3=0`** — leave alone if jog/touch screen are correct |
| **Limits** | **`$20=0`**, **`$21=0`** (off while testing — enable when travel trusted) |
| **MeerK40t** | Bed **405×285 mm**, home **top-left**, **Flip Y on** |

**Homing procedure**

1. **`$X`** — clear alarm  
2. **`?`** — **`Pn:`** must be **empty** at rest  
3. **`$HY`** → wait `ok`  
4. **`$HX`** → wait `ok`  
5. **`?`** — expect **`MPos:0.000,0.000,0.000`**

---

## Annotated settings table

| Setting | Value | Unit | Parameter | Description |
|---------|------:|------|-----------|-------------|
| $0 | 10 | µs | Step pulse time | Length of each step pulse. Minimum ~3 µs. |
| $1 | 25 | ms | Step idle delay | Delay before steppers disable after a stop. **255** = stay enabled. |
| $2 | 0 | mask | Step pulse invert | Invert step pin per axis (bits ZYX). |
| $3 | 0 | mask | Step direction invert | Invert dir pin for **jog/cuts** (not homing — see `$23`). |
| $4 | 0 | bool | Invert step enable | Inverts driver ENABLE pin. |
| $5 | 0 | bool | Invert limit pins | Inverts all limit inputs. |
| $6 | 0 | bool | Invert probe pin | Inverts probe input. |
| $10 | 1 | mask | Status report options | What appears in `?` status reports. |
| $11 | 0.010 | mm | Junction deviation | Cornering smoothness; lower = slower through joins. |
| $12 | 0.002 | mm | Arc tolerance | G2/G3 arc fit error. |
| $13 | 0 | bool | Report in inches | **0** = mm for positions and rates. |
| $20 | 0 | bool | Soft limits | **Off** — enable **1** when homing + travel verified. |
| $21 | 0 | bool | Hard limits | **Off** — enable **1** when limit wiring/jumpers are clean. |
| $22 | 1 | bool | Homing enable | Homing required for soft limits. |
| $23 | 1 | mask | Homing dir invert | Homing search direction only. Andre: **X inverted**, Y OK. |
| $24 | 200.000 | mm/min | Homing locate feed | Slow feed when engaging switch. |
| $25 | 500.000 | mm/min | Homing seek feed | Fast seek before locate. |
| $26 | 250.000 | ms | Homing debounce | Pause between homing phases. |
| $27 | 5.000 | mm | Homing pull-off | Back off after switch trip. |
| $28 | 1000.000 | — | *(ESP32 extension)* | Board-specific; not in standard Grbl wiki. |
| $30 | 1000.000 | RPM | Max spindle/laser | **S1000** = 100% PWM duty. |
| $31 | 50.000 | RPM | Min spindle/laser | Minimum PWM floor when laser on. |
| $32 | 1 | bool | Laser mode | **On** — consecutive G1 moves keep laser state; **M4** power ∝ speed. |
| $38 | 0 | — | *(ESP32 extension)* | Board-specific. |
| $40 | 1 | — | *(ESP32 extension)* | Board-specific. |
| $43 | 0 | — | *(ESP32 extension)* | Board-specific. |
| $49 | 0 | — | *(ESP32 extension)* | Board-specific. |
| $100 | 157.210 | steps/mm | X resolution | Calibrated — trust ruler over theory. |
| $101 | 159.600 | steps/mm | Y resolution | Calibrated. |
| $102 | 100.000 | steps/mm | Z resolution | Z not used (AC focus motor). |
| $103 | 100.000 | steps/mm | A resolution | Unused. |
| $104 | 100.000 | steps/mm | B resolution | Unused. |
| $105 | 100.000 | steps/mm | C resolution | Unused. |
| $110 | 5500.000 | mm/min | X max rate | **Cap for X rapids and cuts** (~91.7 mm/s). |
| $111 | 5000.000 | mm/min | Y max rate | Y cap (~83.3 mm/s). |
| $112 | 6000.000 | mm/min | Z max rate | Z stepper unused on this machine. |
| $113 | 1000.000 | mm/min | A max rate | Unused. |
| $114 | 1000.000 | mm/min | B max rate | Unused. |
| $115 | 1000.000 | mm/min | C max rate | Unused. |
| $120 | 500.000 | mm/s² | X acceleration | How fast X ramps; does not raise `$110` cap. |
| $121 | 400.000 | mm/s² | Y acceleration | Y ramp rate. |
| $122 | 3500.000 | mm/s² | Z acceleration | Unused axis. |
| $123 | 200.000 | mm/s² | A acceleration | Unused. |
| $124 | 200.000 | mm/s² | B acceleration | Unused. |
| $125 | 200.000 | mm/s² | C acceleration | Unused. |
| $130 | 405.000 | mm | X max travel | Match MeerK40t device width. |
| $131 | 285.000 | mm | Y max travel | Into bed = **Y negative** (e.g. toward **−285**). |
| $132 | 300.000 | mm | Z max travel | Unused. |
| $133 | 300.000 | mm | A max travel | Unused. |
| $134 | 300.000 | mm | B max travel | Unused. |
| $135 | 300.000 | mm | C max travel | Unused. |

---

## Raw dump (mirror of canonical `settings`)

Do not edit values here — update [`settings`](settings) first, then regenerate this file.

```text
$0=10
$1=25
$2=0
$3=0
$4=0
$5=0
$6=0
$10=1
$11=0.010
$12=0.002
$13=0
$20=0
$21=0
$22=1
$23=1
$24=200.000
$25=500.000
$26=250.000
$27=5.000
$28=1000.000
$30=1000.000
$31=50.000
$32=1
$49=0
$38=0
$40=1
$43=0
$100=157.210
$101=159.600
$102=100.000
$103=100.000
$104=100.000
$105=100.000
$110=5500.000
$111=5000.000
$112=6000.000
$113=1000.000
$114=1000.000
$115=1000.000
$120=500.000
$121=400.000
$122=3500.000
$123=200.000
$124=200.000
$125=200.000
$130=405.000
$131=285.000
$132=300.000
$133=300.000
$134=300.000
$135=300.000
```

---

## Related docs

- MeerK40t: [`docs/meerk40t/19-dlc32-eeprom-settings.md`](../docs/meerk40t/19-dlc32-eeprom-settings.md)  
- Board + motors: [`docs/meerk40t/16-mks-dlc32-board.md`](../docs/meerk40t/16-mks-dlc32-board.md)  
- Workflow: [`docs/meerk40t/17-meerkat-dlc32-workflow.md`](../docs/meerk40t/17-meerkat-dlc32-workflow.md)
