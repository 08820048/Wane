# Wane

Wane is a native macOS menubar app that renders subtle progress bars along the screen edge for the current workday, week, month, and year.

## Build From Source

Requirements:

- macOS 13 Ventura or newer
- Swift 5.9 or newer

Build and run:

```sh
swift build
swift run Wane
```

Run tests:

```sh
swift test
```

Build a direct-download DMG:

```sh
./scripts/build_release.sh 0.000
```

See `docs/Release.md` for signing, notarization, and Sparkle appcast steps.

## App Icon

The source icon is kept at `docs/wane_icon.png`. The macOS app icon is generated
as `Sources/WaneCore/Resources/WaneIcon.icns` and referenced from
`Config/Wane-Info.plist` via `CFBundleIconFile`.

## Install With Homebrew

Wane is prepared for Homebrew Cask distribution. After the tap repository is
published, users can install with:

```sh
brew tap 08820048/wane
brew install --cask wane
```

See `docs/Homebrew.md` for tap setup and release requirements.

## Software Updates

Wane uses Sparkle 2 for direct-download builds. The code path is wired through
`SoftwareUpdateController`, but Sparkle only starts when the app bundle
`Info.plist` contains both:

- `SUFeedURL`
- `SUPublicEDKey`

Use `Config/Wane-Info.plist` as the template for these keys. Generate Sparkle
signing keys and appcasts with Sparkle's release tools before shipping a
notarized direct-download build.

Current Sparkle public key:

```text
WPgzx2GIqY8DUPWOe6OuHrr1BecMrHaoUknSdM245dw=
```

The matching private key is stored in the local macOS Keychain by Sparkle's
`generate_keys` tool. Do not commit exported private keys.

## Project Layout

```text
Sources/WaneApp        SwiftUI app entry point
Sources/WaneCore/App   Menu bar lifecycle
Sources/WaneCore/Core  Preferences, time calculations, screen management
Sources/WaneCore/Window    Edge windows and progress bar rendering
Sources/WaneCore/Settings  SwiftUI settings and popover UI
```

## License

Apache License 2.0 with Commons Clause. See `LICENSE`.
