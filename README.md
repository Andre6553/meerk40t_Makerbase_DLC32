# Meerkat — Andre's MeerK40t + MKS DLC32 workspace

Local workspace for **K40 CO2 + MKS DLC32** (400×285 mm), MeerK40t fork, docs, firmware reference, and Cursor rules.

## Layout

| Path | Purpose |
|------|---------|
| `docs/meerk40t/` | Knowledge base for Cursor + workflow docs |
| `.cursor/rules/` | Cursor agent rules (DLC32 EEPROM, `/settings`, backups) |
| `Firmware Settings/` | Canonical GRBL `$$` dump (`settings`) |
| `scripts/` | e.g. DLC32 Wi‑Fi wake script |
| `run-meerk40t-dev.bat` | Launch MeerK40t from local venv |
| `designs/`, `images/` | Project assets |
| `MKS dlc32/`, `MKS-DLC32-*` | Board / firmware reference |
| `meerk40t/` | **Not in this repo** — clone separately (below) |

## MeerK40t fork (code)

```powershell
git clone https://github.com/Andre6553/meerk40t.git meerk40t
cd meerk40t
python -m venv .venv
.\.venv\Scripts\pip install -r requirements.txt
```

Run from workspace root: `run-meerk40t-dev.bat`

## Secrets

Copy `.env.example` to `.env` locally (router login, etc.). **`.env` is gitignored.**
