# Planner and spooler (expanded)

This document is the **second-pass** deep dive chosen for maximum leverage: every driver (Lihuiyu, GRBL, Ruida, …) ultimately receives work through the same **plan → spool → driver.execute** pattern.

---

## 1. Concepts (vocabulary)

| Term | Meaning |
|------|--------|
| **Operation** | A node in the tree that groups work (cut, raster, image, util ops like home/wait). |
| **CutPlan** | Named pipeline that turns copied operations into **CutCode** (and related spoolable steps), through staged processing. |
| **Planner** | Kernel **service** (`kernel.add_service("planner", Planner(kernel))`) that owns named `CutPlan`s, exposes `plan` console commands, and tracks **stage** state per plan. |
| **CutCode** | Executable sequence of cut primitives the driver can consume (see `meerk40t/core/cutcode/`). |
| **LaserJob** | Spooler job wrapping a **list** of items (often `CutCode` chunks); `execute()` walks the list and calls into the **driver**. |
| **Spooler** | **Per-device** threaded queue: runs `LaserJob` and other jobs by calling `job.execute(driver)` until done. |

Module docstrings to read first:

- `meerk40t/core/planner.py` (top) — planner → cutcode → laserjob → spooler.
- `meerk40t/core/spoolers.py` (top) — spooler commands; `Spooler` processes jobs in order.
- `meerk40t/core/cutplan.py` (top + `CutPlan` class docstring) — **stage** definitions.

---

## 2. Plan stages (CutPlan)

`CutPlan` documents the intended progression (`meerk40t/core/cutplan.py`, class `CutPlan`):

1. **Copy** — `copy` / `copy-selected`: operations (and referenced geometry) are copied into the plan; refs become real nodes.
2. **Preprocess** — Scene space → device space; validation hooks may be attached.
3. **Validate** — Runs validation “execute” steps.
4. **Blob** — Operations become **cutcode** (or other spoolable representation).
5. **Preopt** — Inserts optimization structure (travel, inner-first, sequencing).
6. **Optimize** — Runs the optimization passes.

Numeric stage constants live in `meerk40t/core/planner.py` (e.g. `STAGE_PLAN_BLOB = 8`, `STAGE_PLAN_FINISHED = 99`).  
`Planner.STAGE_DESCRIPTIONS` maps constants to short labels for UI/console (`Planner` class in same file).

**Why “blob” matters:** The `spool` console command refuses to enqueue a plan until the **blob** stage is present — otherwise there is nothing safe to send (`spoolers.py`, `spool` command checks `STAGE_PLAN_BLOB not in stage`).

---

## 3. Planner service (`Planner`)

- **Registration:** `planner.plugin` → `lifecycle == "register"` → `kernel.add_service("planner", Planner(kernel))`.
- **Storage:** `_plan` dict: plan name → `CutPlan` instance; `_states` tracks timestamps per stage.
- **Default plan name:** string `"0"` (`_default_plan`), used when console says `plan` without a suffix.
- **Threading:** `_plan_lock` wraps get/create plan APIs (`get_or_make_plan`).

**User-facing settings** (examples from `planner.plugin` boot):

- `auto_spooler` — open Job Spooler window when a job is started (`Launch Spooler on Job Start`).
- Many **optimisation** choices (`opt_reduce_travel`, raster clustering, etc.) — read the `choices = [...]` blocks in `planner.py` for exact attrs and tooltips.

**Console:** `plan`, `plan<?>`, `list-plans`, and subcommands like `copy`, `preprocess`, `validate`, `blob`, `preopt`, `optimize`, `clear`, `spool` are wired through this service (see `plan_base` and following `@self.console_command` handlers in `Planner.service_attach`).

---

## 4. Typical GUI command chain

From `wxmmain.py` job start logic (already in your KB): the UI builds a **console string** that roughly does:

- `plan<N> clear copy preprocess validate blob [preopt optimize] spool`

Optimization segments depend on `kernel.planner.do_optimization` (root setting `do_optimization`).

That keeps the **UI thin** and reuses the same pipeline as power users typing console commands.

---

## 5. Spooler (`Spooler` class)

Defined in `meerk40t/core/spoolers.py`.

**Responsibilities:**

- Holds a **queue** (`_queue`) of jobs with **priority** (sorted on insert).
- Runs a **dedicated thread** (`restart()` → `context.threaded(self.run, ...)`).
- Each cycle: pick next enabled job, respect `driver.hold_work(priority)` (pause / busy), call `program.execute(self.driver)`.
- If `execute` returns **True**, job is **removed**; optional `driver.job_finish(program)`.
- If **False**, job is **not** finished — spooler will call `execute` again on a later cycle (cooperative multitasking for long streams).

**`laserjob(...)`** wraps an iterable `job` into a **`LaserJob`** (`meerk40t/core/laserjob.py`): label, items, driver reference, **loops** (infinite allowed for continuous mode), optional **outline** bounds.

**LaserJob.execute:** iterates `items`; items may be `CutCode` or tuples mapping to driver methods — see `laserjob.py` for `execute_item` / `calc_steps`.

---

## 6. Console commands you can use for debugging

Registered in `spoolers.py` (partial list):

| Command pattern | Role |
|-----------------|------|
| `spool` | With a **plan** as typed input: finalize plan, build `LaserJob`, enqueue; without args: **list** devices and queue. |
| `spool<?> list` | List queued jobs on current spooler. |
| `spool<?> clear` | Clear queue. |
| `send` (on spooler type) | Send a registered **plan command** by name (see `kernel.find("plan", op)`). |
| Jog helpers | `left`/`right`/`up`/`down` with `Length`, `jog`, `+laser`/`-laser` (some hidden) — see same file. |

Planner:

| Command | Role |
|---------|------|
| `list-plans` | Show all plan names and stage summary. |
| `plan` / `plan<?>` | Select default plan suffix; show plan contents when no remainder. |
| `plan<?> copy` / `copy-selected` | Seed plan from operations. |

Always prefer reading the **exact** `@kernel.console_command` / `@self.console_command` blocks in `planner.py` and `spoolers.py` for syntax—this table is a map, not a full manual.

---

## 7. UI: Job Spooler window

`meerk40t/gui/spoolerpanel.py` — `JobSpooler` / `SpoolerPanel` show queue state and controls. Tied to the same `kernel.device.spooler` object the console manipulates.

---

## 8. Relationship to drivers

Each **device** exposes a **`.spooler`** instance bound to that device’s **driver**. The planner is **global** as a service; **plans** are handed to the **active device’s** spooler when you spool.

So when switching devices in the UI, the target of `spool` changes with `kernel.device`.

---

## 9. Suggested reading order (this subsystem)

1. `core/cutplan.py` — `CutPlan` class docstring (stages).
2. `core/planner.py` — constants + `Planner` + first `plan_*` commands.
3. `core/spoolers.py` — `spool` command + `Spooler` + `laserjob`.
4. `core/laserjob.py` — how items are stepped.
5. `core/cutcode/cutcode.py` (as needed) — structure of emitted cut primitives.

---

## 10. Future doc slices (not done here)

- **GRBL** / **Ruida**: how their drivers implement `hold_work`, `job_start`, and map `CutCode` to wire protocol (separate files).
- **Console catalog**: alphabetical command index (incremental; many commands across plugins).
