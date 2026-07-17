# Caffeinated

A small macOS menu bar app that keeps your Mac awake for a chosen duration. A spiritual successor to the old [Caffeine](https://en.wikipedia.org/wiki/Caffeine_(application)) applet, rebuilt with SwiftUI for modern macOS.

## Features

- Live in the menu bar — no Dock icon, no window clutter
- Keep awake for 15 min, 30 min, 1 hr, 2 hr, 5 hr, or indefinitely
- Keep awake until a specific time of day (rolls over to tomorrow if the time has already passed)
- Keeps both display and system awake (uses `PreventUserIdleDisplaySleep`)
- Closing the lid still sleeps the Mac — by design
- Optional launch at login (via `SMAppService`)
- Optional restore of previous awake state after relaunch

## Requirements

- macOS 14 (Sonoma) or later
- Xcode 15 or later
- [xcodegen](https://github.com/yonaskolb/XcodeGen) to generate the Xcode project

## Build from source

```sh
brew install xcodegen
git clone https://github.com/<your-username>/Caffeinated.git
cd Caffeinated
xcodegen generate
open Caffeinated.xcodeproj
```

In Xcode, hit `⌘R`. The default signing setting ("Sign to Run Locally") works for personal use — no Apple Developer account required.

To make it a permanent menu bar app, drag the built `Caffeinated.app` from Xcode's build folder into `/Applications`, then enable "Launch at login" in its Settings.

## How it works

The app holds an [IOKit power assertion](https://developer.apple.com/documentation/iokit/iopmlib_h/iopmassertioncreatewithname) of type `PreventUserIdleDisplaySleep` while active. Releasing the assertion returns the Mac to normal sleep behavior. The shell command `caffeinate -d` uses the same mechanism.

## License

MIT — see [LICENSE](LICENSE).
