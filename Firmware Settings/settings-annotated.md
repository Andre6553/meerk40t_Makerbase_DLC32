# GRBL EEPROM — annotated (`Firmware Settings/settings`)

**Source:** live dump in `settings` (values not edited here).  
**Board UI:** ESP32-WEB → Control → SD / File / Settings.  
**When values change:** update `settings` first, then regenerate this file (say **`/settings`** in Cursor).

---

| Setting | Value | Unit | Parameter | Description |
|---------|------:|------|-----------|-------------|
| $0 | 10 | microseconds | Step pulse time | Sets time length per step. Minimum 3usec. |
| $1 | 25 | milliseconds | Step idle delay | Sets a short hold delay when stopping to let dynamics settle before disabling steppers. Value 255 keeps motors enabled with no delay. |
| $2 | 0 | mask | Step pulse invert | Inverts the step signal. Set axis bit to invert (00000ZYX). |
| $3 | 0 | mask | Step direction invert | Inverts the direction signal. Set axis bit to invert (00000ZYX). |
| $4 | 0 | boolean | Invert step enable pin | Inverts the stepper driver enable pin signal. |
| $5 | 0 | boolean | Invert limit pins | Inverts all of the limit input pins. |
| $6 | 0 | boolean | Invert probe pin | Inverts the probe input pin signal. |
| $10 | 1 | mask | Status report options | Alters data included in status reports. |
| $11 | 0.010 | mm | Junction deviation | Sets how fast Grbl travels through consecutive motions. Lower value slows it down. |
| $12 | 0.002 | mm | Arc tolerance | Sets the G2 and G3 arc tracing accuracy based on radial error. Beware: A very small value may affect performance. |
| $13 | 0 | boolean | Report in inches | Enables inch units when returning any position and rate value that is not a settings value. |
| $20 | 0 | boolean | Soft limits enable | Enables soft limits checks within machine travel and sets alarm when exceeded. Requires homing. |
| $21 | 0 | boolean | Hard limits enable | Enables hard limits. Immediately halts motion and throws an alarm when switch is triggered. |
| $22 | 1 | boolean | Homing cycle enable | Enables homing cycle. Requires limit switches on all axes. |
| $23 | 1 | mask | Homing direction invert | Homing searches for a switch in the positive direction. Set axis bit (00000ZYX) to search in negative direction. |
| $24 | 200.000 | mm/min | Homing locate feed rate | Feed rate to slowly engage limit switch to determine its location accurately. |
| $25 | 500.000 | mm/min | Homing search seek rate | Seek rate to quickly find the limit switch before the slower locating phase. |
| $26 | 250.000 | milliseconds | Homing switch debounce delay | Sets a short delay between phases of homing cycle to let a switch debounce. |
| $27 | 5.000 | mm | Homing switch pull-off distance | Retract distance after triggering switch to disengage it. Homing will fail if switch isn't cleared. |
| $28 | 1000.000 | — | *(ESP32-WEB extension)* | Board-specific setting; not in standard Grbl wiki table. |
| $30 | 1000.000 | RPM | Maximum spindle speed | Maximum spindle speed. Sets PWM to 100% duty cycle. |
| $31 | 50.000 | RPM | Minimum spindle speed | Minimum spindle speed. Sets PWM to 0.4% or lowest duty cycle. |
| $32 | 1 | boolean | Laser-mode enable | Enables laser mode. Consecutive G1/2/3 commands will not halt when spindle speed is changed. |
| $38 | 0 | — | *(ESP32-WEB extension)* | Board-specific setting; not in standard Grbl wiki table. |
| $40 | 1 | — | *(ESP32-WEB extension)* | Board-specific setting; not in standard Grbl wiki table. |
| $43 | 0 | — | *(ESP32-WEB extension)* | Board-specific setting; not in standard Grbl wiki table. |
| $49 | 0 | — | *(ESP32-WEB extension)* | Board-specific setting; not in standard Grbl wiki table. |
| $100 | 157.210 | steps/mm | X-axis travel resolution | X-axis travel resolution in steps per millimeter. |
| $101 | 159.600 | steps/mm | Y-axis travel resolution | Y-axis travel resolution in steps per millimeter. |
| $102 | 100.000 | steps/mm | Z-axis travel resolution | Z-axis travel resolution in steps per millimeter. |
| $103 | 100.000 | steps/mm | A-axis travel resolution | A-axis travel resolution in steps per millimeter. |
| $104 | 100.000 | steps/mm | B-axis travel resolution | B-axis travel resolution in steps per millimeter. |
| $105 | 100.000 | steps/mm | C-axis travel resolution | C-axis travel resolution in steps per millimeter. |
| $110 | 5000.000 | mm/min | X-axis maximum rate | X-axis maximum rate. Used as G0 rapid rate. |
| $111 | 5000.000 | mm/min | Y-axis maximum rate | Y-axis maximum rate. Used as G0 rapid rate. |
| $112 | 6000.000 | mm/min | Z-axis maximum rate | Z-axis maximum rate. Used as G0 rapid rate. |
| $113 | 1000.000 | mm/min | A-axis maximum rate | A-axis maximum rate. Used as G0 rapid rate. |
| $114 | 1000.000 | mm/min | B-axis maximum rate | B-axis maximum rate. Used as G0 rapid rate. |
| $115 | 1000.000 | mm/min | C-axis maximum rate | C-axis maximum rate. Used as G0 rapid rate. |
| $120 | 350.000 | mm/sec² | X-axis acceleration | X-axis acceleration. Used for motion planning to not exceed motor torque and lose steps. |
| $121 | 350.000 | mm/sec² | Y-axis acceleration | Y-axis acceleration. Used for motion planning to not exceed motor torque and lose steps. |
| $122 | 3500.000 | mm/sec² | Z-axis acceleration | Z-axis acceleration. Used for motion planning to not exceed motor torque and lose steps. |
| $123 | 200.000 | mm/sec² | A-axis acceleration | A-axis acceleration. Used for motion planning to not exceed motor torque and lose steps. |
| $124 | 200.000 | mm/sec² | B-axis acceleration | B-axis acceleration. Used for motion planning to not exceed motor torque and lose steps. |
| $125 | 200.000 | mm/sec² | C-axis acceleration | C-axis acceleration. Used for motion planning to not exceed motor torque and lose steps. |
| $130 | 405.000 | mm | X-axis maximum travel | Maximum X-axis travel from homing switch. Determines valid machine space for soft limits and homing search distances. |
| $131 | 285.000 | mm | Y-axis maximum travel | Maximum Y-axis travel from homing switch. Determines valid machine space for soft limits and homing search distances. |
| $132 | 300.000 | mm | Z-axis maximum travel | Maximum Z-axis travel from homing switch. Determines valid machine space for soft limits and homing search distances. |
| $133 | 300.000 | mm | A-axis maximum travel | Maximum A-axis travel from homing switch. Determines valid machine space for soft limits and homing search distances. |
| $134 | 300.000 | mm | B-axis maximum travel | Maximum B-axis travel from homing switch. Determines valid machine space for soft limits and homing search distances. |
| $135 | 300.000 | mm | C-axis maximum travel | Maximum C-axis travel from homing switch. Determines valid machine space for soft limits and homing search distances. |

---

## Raw dump (canonical — do not edit here; edit `settings`)

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
$110=5000.000
$111=5000.000
$112=6000.000
$113=1000.000
$114=1000.000
$115=1000.000
$120=350.000
$121=350.000
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
