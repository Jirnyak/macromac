# MacroMac

Open-source JSON macro runner for macOS desktop automation.

![MacroMac demo](assets/demo.gif)

MacroMac records mouse and keyboard input over live applications, stores it as editable JSON, and replays it with simple synchronization blocks: delays, shell commands, file signals, and polling conditions.

It is universal in the low-level sense: it does not need app-specific APIs, browser extensions, or per-site integrations. If a workflow can be driven by mouse, keyboard, files, and shell commands, Macro can usually represent it.

It is intentionally low-level. MacroMac does not understand UI semantics, recover from changed layouts, or know whether the correct window is focused.

## Status

Experimental macOS tooling for personal automation, prototyping, and script-driven desktop workflows.

## What It Does

- Opens a native macOS launcher for choosing, editing, and running macro JSON files.
- Records live mouse, click, and keyboard input into `step` blocks.
- Replays real input through macOS event APIs.
- Stores workflows as plain JSON in `blocks`.
- Supports fixed delays, shell commands, file-change signals, and shell polling conditions.
- Discards human recording time; playback timing is controlled by `pace`.
- Runs in headless runner and hotkey supervisor modes.
- Lets each macro define its own launch hotkey.

## What It Is Not

- Not image recognition.
- Not OCR.
- Not accessibility-tree automation.
- Not browser automation like Selenium or Playwright.
- Not an API replacement when a stable API exists.
- Not resilient to arbitrary app layout changes.
- Not safe to run with untrusted JSON.

## Requirements

- macOS 13 or newer.
- Swift 5.9+ / Xcode Command Line Tools.

Install command line tools if needed:

```sh
xcode-select --install
```

## Download

For normal use, download the built `MacroMac-macos-universal.zip` asset from GitHub Releases, unzip it, and open `Macro.command`.

The GitHub-generated "Source code" archives are not ready-to-run app builds. Use the attached release zip.

The release build is a universal macOS binary for Apple Silicon and Intel Macs. It is unsigned and not notarized, so macOS may require manual approval on first launch.

## Security And Privacy

Macro is powerful because it can observe and synthesize real desktop input.

macOS may ask for:

- **Accessibility** - allows Macro to move the cursor, click, and type.
- **Input Monitoring** - allows Macro to observe keyboard and hardware key events.
Grant permissions in `System Settings -> Privacy & Security -> Accessibility / Input Monitoring`. Depending on how you launch Macro, macOS may ask you to grant permission to Terminal, the Swift-built `macro` binary, or both.
Relaunch Macro after changing permissions.

Macro JSON is trusted code:

- `step` blocks can click and type into real applications.
- `command` and `condition` blocks run through `$SHELL -lc`, falling back to `/bin/zsh -lc`.
- Macros can alter the clipboard, move files, delete files, submit forms, or trigger app actions.

Only run macro files you understand. Do not run untrusted JSON.

Recorded macros can also reveal private workflow details: screen coordinates, app layout, keyboard actions, file paths, and shell commands. This repository intentionally ignores `macros/*.json`.

## Quick Start

From the repository root:

```sh
swift run macro
```

This opens the native launcher. From there:

- `New / Overwrite` opens the editor for a new or selected macro.
- `Edit Steps` rewrites only the existing `step` blocks in a selected macro.
- `Run` starts the selected macro in runner mode.
- `Open JSON` opens the selected macro file in your default editor.
- `Hotkeys` starts the background supervisor for macros with top-level `hotkey`.

The launcher reads `./macros/*.json` relative to the current working directory.

## Finder Launchers

The repository includes simple double-click launchers:

- `Macro.command` - opens the launcher.
- `Example.command` - runs the safe example macro from `macros/example.json`.
- `Hotkeys.command` - starts the background hotkey supervisor.

These are plain shell scripts. macOS may require confirmation the first time you open them.

## Standalone Build

The development launchers use `swift run`, so the development machine needs the Swift toolchain.

To create a folder that can be copied to another Mac without installing Swift there:

```sh
./PackageRelease.command
```

This creates `dist/MacroMac/` and `dist/MacroMac-macos-universal.zip` with:

- `macro` - release executable.
- `Macro.command` - opens the launcher using the bundled executable.
- `Example.command` - runs the bundled example macro.
- `Hotkeys.command` - starts the bundled hotkey supervisor.
- `macros/example.json` - safe sample macro.
- `macro.config.example.json` - optional controls template.

The target Mac still needs compatible macOS permissions for Accessibility and Input Monitoring. For public distribution outside your own machines, code signing and notarization are recommended to avoid Gatekeeper warnings.

## Controls

In the overlay editor:

- `F1` - start or stop recording the current `step`.
- `F2` - cancel the current recorded `step` and record the same step again.
- `F3` - run or stop playback.
- `F4` - quit.

In runner mode:

- `F3` - run or stop the loaded macro.
- `F4` - quit.

Top-row function keys are fragile on macOS. Depending on keyboard settings and hardware, brightness/Mission Control/Launchpad keys may map to the same physical keys. Input Monitoring permission may be required for reliable handling.

Editor and runner controls can be changed in `macro.config.json`:

```json
{
  "version": 1,
  "controls": {
    "record": { "key": "F1" },
    "cancelStep": { "key": "F2" },
    "playback": { "key": "F3" },
    "quit": { "key": "F4" }
  }
}
```

If `macro.config.json` is missing, these defaults are used. `macro.config.example.json` is committed as a template; `macro.config.json` is local and ignored by git.

Hotkeys use:

```json
{ "key": "F8", "modifiers": ["control", "option"] }
```

or a raw macOS virtual key code:

```json
{ "keyCode": 100, "modifiers": ["control", "option"] }
```

Supported named keys include `F1` through `F20`, `A` through `Z`, `0` through `9`, `space`, `tab`, `return`, `escape`, `delete`, `left`, `right`, `up`, and `down`. Supported modifiers are `command`, `control`, `option`, `shift`, and `function`.

## Modes

Open launcher:

```sh
swift run macro
```

Open editor directly:

```sh
swift run macro -- --editor
```

Record into a specific file:

```sh
swift run macro -- --editor --macro my-flow.json
```

Rewrite only existing `step` blocks:

```sh
swift run macro -- --editor --rewrite-steps --macro my-flow.json
```

Run a macro in headless mode and wait for `F3`:

```sh
swift run macro -- --runner --macro my-flow.json
```

Run immediately:

```sh
swift run macro -- --runner --play --macro my-flow.json
```

Start the hotkey supervisor:

```sh
swift run macro -- --hotkeys
```

In this mode MacroMac scans `./macros/*.json`, loads every macro with a top-level `hotkey`, and keeps running in the background. Pressing a macro hotkey starts that macro. Pressing the same hotkey again stops it. Pressing another macro hotkey stops the current macro and starts the new one.

Restart the supervisor after adding, removing, or changing macro `hotkey` fields.

Local shortcut mode:

```sh
swift run macro -- --dialog dialog.json
```

`--dialog` is a shortcut for headless runner plus immediate play. If no file is provided, it uses `macros/dialog.json`. This is intended for local custom scenarios; `dialog.json` is ignored by git.

## Workflow

1. Record one or more `step` blocks in the overlay editor.
2. Edit the JSON manually or with another tool.
3. Add `delay`, `command`, `condition`, or `signal` blocks between steps.
4. Run the JSON through the launcher, runner, or a `.command` script.
5. If the UI moved, use `Edit Steps` to rewrite only the recorded input while keeping the surrounding logic.

The editor records input order, not human timing. If you pause while thinking during recording, that pause is not stored.

## JSON Model

A macro is a flat ordered list of `blocks`.

```json
{
  "version": 3,
  "hotkey": {
    "key": "F8",
    "modifiers": ["control", "option"]
  },
  "sourceScreen": { "width": 1512, "height": 982 },
  "loop": true,
  "blocks": [
    {
      "kind": "step",
      "name": "open field",
      "pace": 0.1,
      "actions": [
        { "kind": "move", "x": 0.5, "y": 0.5 },
        { "kind": "leftClick", "x": 0.5, "y": 0.5 },
        { "kind": "keyDown", "x": 0.5, "y": 0.5, "keyCode": 49, "modifiers": 0 },
        { "kind": "keyUp", "x": 0.5, "y": 0.5, "keyCode": 49, "modifiers": 0 }
      ]
    },
    { "kind": "condition", "command": "test -f ready.txt", "poll": 1, "timeout": 60 },
    { "kind": "command", "command": "cp ready.txt output.txt", "timeout": 10 },
    { "kind": "delay", "seconds": 1 }
  ]
}
```

If `loop` is `true`, playback returns to block `0` after the final block. A pause before the next cycle should be modeled as the final `delay`.

`hotkey` is optional. It is used only by `--hotkeys`; normal editor and runner modes ignore it.

## Blocks

### `step`

Recorded input: cursor movement, mouse down/up, clicks, and key down/up actions.

Important fields:

- `actions` - ordered input actions.
- `pace` - synthetic seconds between actions. Default: `0.1`.
- `compactMoves` - if true, consecutive movement-only runs are compacted.

Playback begins with the first action. Include an initial `move` action when the cursor should move before the first click or key event.

Slow or animated UI often needs `pace` around `0.2` to `0.35`.

### `delay`

Fixed wait:

```json
{ "kind": "delay", "seconds": 5 }
```

Use this only when fixed time is the right synchronization primitive.

### `command`

Run one shell command once:

```json
{ "kind": "command", "command": "cp input.txt output.txt", "timeout": 10 }
```

The macro continues only if the command exits with code `0`. A non-zero exit stops playback.

### `condition`

Poll a shell command until it exits with code `0`:

```json
{ "kind": "condition", "command": "test -s answer.txt", "poll": 1, "timeout": 120 }
```

Use `condition` when another system needs time to produce a file, text, state, or any shell-checkable result.

### `signal`

Wait for a file to be created or modified:

```json
{ "kind": "signal", "path": "signal.txt", "poll": 0.1 }
```

Macro snapshots file existence, size, and modification time on entry. It continues only after that state changes. Another process can release the macro with:

```sh
date +%s%N > signal.txt
```

## Repeat And Handoff

MacroMac does not need separate `repeat`, `pause`, or "cyborg mode" blocks.

- Repeat the whole macro with top-level `"loop": true`.
- Pause between cycles with a final `delay`.
- Pause for a human, agent, or another process with `signal`.
- Wait for a real condition with `condition`.
- Let external logic branch, count, or decide with `command` and files.

This keeps the core language flat: `step -> command/condition/signal/delay -> step`.

## Input Actions

Supported `action.kind` values inside a `step`:

- `move`
- `leftClick`
- `rightClick`
- `leftDown`
- `leftUp`
- `rightDown`
- `rightUp`
- `keyDown`
- `keyUp`

Coordinates are normalized from `0` to `1` against the source screen. Playback maps them to the current main display. This helps with screen size differences, but it does not make workflows layout-independent.

For exact playback, keep the same:

- main display
- app/window placement
- focused app
- keyboard layout/input source
- macOS Space/full-screen state
- target app state

## Overlay Behavior

Normal recording happens over the real desktop. The overlay ignores mouse events and uses a listen-only event tap, so input continues to reach the real applications. `F2` clears only the currently recording step; already saved steps and non-step blocks stay unchanged.

## Limitations

- Main-display oriented.
- Coordinate-based, not semantic UI automation.
- No built-in image recognition or OCR.
- No automatic recovery if a window, dialog, or loading state changes.
- No per-action recorded timing.
- Hotkey events are listen-only; choose shortcuts that do not conflict with the active app.
- Runner errors currently go to system logs / Terminal output, not a rich run report.
- Shell commands are trusted code.
- macOS permissions can silently break capture or playback if not granted.

Macro works best for controlled, repeatable workflows where you can express readiness with files, shell checks, or explicit waits.

## Git Hygiene

This repository ignores generated and personal files:

- `.build/`
- `.DS_Store`
- `*.log`
- `Dialog.command`
- `macro.config.json`
- `tmp/`
- `macros/*.json` except `macros/example.json`

Do not commit personal macro JSON or local launcher scripts. Recorded macros may contain private screen coordinates, app workflows, file paths, prompt paths, clipboard logic, or destructive shell commands.

## Development

Build:

```sh
swift build
```

Test:

```sh
swift test
```

Run launcher:

```sh
swift run macro
```

Run the safe committed example:

```sh
swift run macro -- --runner --play --macro example.json
```

Run a macro immediately:

```sh
swift run macro -- --runner --play --macro my-flow.json
```

Run the hotkey supervisor:

```sh
swift run macro -- --hotkeys
```

Regenerate the README demo GIF:

```sh
./scripts/render-demo-gif.command
```

## License

MIT. See [LICENSE](LICENSE).

## Non-goals

Macro intentionally stays small. More intelligent layers, such as OCR, image matching, LLM processing, or app-specific logic, should live outside the core and communicate through files, shell commands, `condition`, or `signal`.
