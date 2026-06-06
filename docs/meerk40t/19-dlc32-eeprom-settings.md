# MKS DLC32 — Andre’s confirmed GRBL EEPROM (reference)

**Saved:** 2026-06-05 — live `$$` from the board.  
**Canonical file (Andre):** `Firmware Settings/settings` (raw `$$` dump — update here when board EEPROM changes).  
**Cursor rule:** `.cursor/rules/dlc32-eeprom-settings.mdc` (always applied in this workspace).  
**Bed travel:** **`$130=405`**, **`$131=285`** mm  

See also: [16-mks-dlc32-board.md](16-mks-dlc32-board.md), [17-meerkat-dlc32-workflow.md](17-meerkat-dlc32-workflow.md).

---

## Homing (always)

1. **`$X`** — clear alarm  
2. **`?`** — **`Pn:` must be empty** at rest (no X, Y, P)  
3. **`$HY`** — wait `ok`  
4. **`$HX`** — wait `ok`  
5. **`?`** — expect **`MPos:0.000,0.000,0.000`**, no `Pn:`

**Do not use `$H`** (both axes at once) on this machine.

---

## Direction — two different settings

| Setting | Controls | Andre’s value |
|---------|----------|---------------|
| **`$3`** | Jog, cuts, touch-screen arrows | **`0`** (no invert) |
| **`$23`** | Homing search direction only | **`1`** (invert X homing; Y homing correct at `$23=0`) |

**Rule:** If jog + touch screen are correct, **do not change `$3`** — tune **`$23`** only for homing.

---

## Full EEPROM (`$$` — authoritative 2026-06-05)

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
$31=0.000
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
$110=5000.000
$111=5000.000
$112=6000.000
$113=1000.000
$114=1000.000
$115=1000.000
$120=2400.000
$121=2400.000
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

**Note:** **`$20=0`** and **`$21=0`** in this snapshot = limits disabled while testing. When travel is verified, set **`$20=1`** and **`$21=1`**.

---

## MeerK40t device profile

| Setting | Value |
|---------|--------|
| Profile | **K40 CO2 — MKS DLC32 (405×285 mm)** (`grbl-dlc32-k40-400`) |
| Bed | **405 × 285 mm** (match **`$130`/`$131`**) |
| Home corner | **top-left** |
| Flip Y | **On** |
| Sequential homing | **On** (`$HY` then `$HX`) |
| TCP | `192.168.10.90:8080` |

After homing: **`MPos ≈ 0,0,0`**. Into the bed: **X+** (to **405**), **Y−** (to **−285**).
