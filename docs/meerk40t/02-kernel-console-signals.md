# Kernel, console, channels, signals

## Kernel (`meerk40t/kernel/kernel.py`)

The **`Kernel`** class is described in its docstring as the central hub:

- Plugin lifecycle (`init` → … → `shutdown` / `end`; restart supported)
- **Scheduler** and **jobs**
- **Signals** and listeners (`signal_listener` in UI and drivers)
- **Channels** (named streams of messages; e.g. `"console"`)
- **Console** command parsing and registration
- **Settings** persistence (inherits `Settings`; profile `MeerK40t.cfg` by default)

When debugging “why didn’t X update the UI?”, think: **signal fired?** listener on main thread? **context** path correct?

## Console vs terminal

- **OS terminal** — where you launched `python meerk40t.py`; shows Python tracebacks and anything printed to stdout.
- **In-app Console pane** — UI bound to the **`console`** channel (`meerk40t/gui/consolepanel.py`): displays kernel console output and accepts MeerK40t **console language** input.

The kernel creates a default console channel:

```python
self._console_channel = self.channel("console", timestamp=True, ansi=True)
```

(see `Kernel.__init__` in `kernel.py`).

## Registering commands

Plugins and modules use decorators from `meerk40t/kernel/functions.py` (re-exported via `kernel` / `context`), e.g.:

- `@context.console_command(...)` — user-typed verbs
- `@context.console_option(...)` — flags for those commands

Example in `consolepanel.py`: `cls` / `clear`, `console_font`.

## Signals

**Signals** are string events (e.g. `"laser_armed"`, `"pause"`, `"device;modified"`). Components **listen** with `@signal_listener("...")` and update UI or driver state.

Use signals to follow **side effects**: e.g. arm/disarm toggles `kernel.root._laser_may_run` and emits `"laser_armed"` (see `wxmmain.py` / `laserpanel.py`).

## Channels

**Channels** are for **log-style** or stream output (`channel("console")`, etc.). UI can **watch** a channel to append text (console panel).

## Practical tip

If you add a feature:

1. Decide: **command** (user types it), **signal** (internal event), or **both**.
2. Keep heavy work off the UI thread; use kernel scheduler patterns already used in the file you are editing.
