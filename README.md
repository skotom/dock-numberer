# Dock Numberer

A tiny native macOS (Apple Silicon) menu bar app: press **⌘1 … ⌘9** to open the first nine apps pinned in your Dock, and **⌘0** to open the tenth.

If the app is already running, it's brought to the front. If it isn't, it's launched. Finder isn't counted, so slot 1 is the first app after Finder.

## Build

Requires the Xcode Command Line Tools (`xcode-select --install`). The full Xcode app is not needed.

```bash
./scripts/build-app.sh
open build/DockNumberer.app
```

To install, copy `build/DockNumberer.app` into `/Applications`, then enable **Launch at Login** from the menu bar icon.

## How it works

- `DockReader.swift` reads the Dock's `persistent-apps` preference (`com.apple.dock`) and skips spacers.
- `HotKeys.swift` registers global hotkeys with Carbon `RegisterEventHotKey`. This needs no Accessibility permission.
- `main.swift` provides the menu bar UI. The menu lists the current slot mapping, a Launch at Login toggle (`SMAppService`), and Quit.

The Dock is re-read on every key press, so rearranging the Dock takes effect immediately.

## Note

While Dock Numberer is running, it takes over ⌘1…⌘0 in every app, so shortcuts like browser tab switching stop working. Snap behaves the same way.
