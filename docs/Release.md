# Release Process

## Build

Build a direct-download release package with:

```sh
./scripts/build_release.sh 0.0001
```

The script creates:

```text
dist/Wane.app
dist/Wane-0.0001.dmg
dist/Wane.dmg
```

`Wane.dmg` is a copy of the versioned DMG for Homebrew's latest-release cask
URL. The DMG contains `Wane.app` and an `Applications` symlink so users can drag
the app into `/Applications`.

## Version Format

Wane versions start at `0.0001` and use the same value for both:

- `CFBundleShortVersionString`
- `CFBundleVersion`

## Signing

The build script automatically uses the first available Developer ID
Application signing identity. Override it with:

```sh
CODESIGN_IDENTITY="Developer ID Application: Name (TEAMID)" ./scripts/build_release.sh 0.0001
```

If no Developer ID identity is available, the script falls back to ad-hoc
signing.

## Notarization

Developer ID signing is not enough for public distribution. Configure a
notarytool profile first:

```sh
xcrun notarytool store-credentials WaneNotary \
  --apple-id "APPLE_ID_EMAIL" \
  --team-id "TEAM_ID" \
  --password "APP_SPECIFIC_PASSWORD"
```

Then submit and staple:

```sh
xcrun notarytool submit dist/Wane-0.0001.dmg \
  --keychain-profile WaneNotary \
  --wait

xcrun stapler staple dist/Wane-0.0001.dmg
xcrun stapler validate dist/Wane-0.0001.dmg
```

After stapling, rerun checksum and Sparkle appcast generation because the DMG
contents have changed.

Verify the mounted app with Gatekeeper:

```sh
MOUNT_DIR=$(mktemp -d /tmp/wane-dmg.XXXXXX)
hdiutil attach dist/Wane-0.0001.dmg -mountpoint "$MOUNT_DIR" -nobrowse -quiet
spctl -a -vv --type execute "$MOUNT_DIR/Wane.app"
hdiutil detach "$MOUNT_DIR" -quiet
rmdir "$MOUNT_DIR"
```

## Sparkle Appcast

Generate appcast metadata after the final DMG is signed and notarized:

```sh
mkdir -p /tmp/wane-appcast-input
cp dist/Wane-0.0001.dmg /tmp/wane-appcast-input/Wane-0.0001.dmg
cat > /tmp/wane-appcast-input/Wane-0.0001.md <<'EOF'
# Wane 0.0001

Initial direct-download build.
EOF

/path/to/Sparkle/bin/generate_appcast \
  --embed-release-notes \
  --download-url-prefix "https://github.com/08820048/Wane/releases/download/v0.0001/" \
  --link "https://github.com/08820048/Wane" \
  -o dist/appcast.xml \
  /tmp/wane-appcast-input
```

Upload these release assets to GitHub Release `v0.0001`:

- `Wane-0.0001.dmg`
- `Wane.dmg`
- `appcast.xml`
