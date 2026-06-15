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
